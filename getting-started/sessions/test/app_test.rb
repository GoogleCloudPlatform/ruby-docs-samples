# frozen_string_literal: true

# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ENV["RACK_ENV"] = "test"

require "digest/sha2"
require "minitest/autorun"
require "rack/test"

require_relative "../app"

class FakeFirestoreSnapshot
  attr_reader :fields

  def initialize fields
    @fields = fields
  end

  def exists?
    !@fields.nil?
  end
end

class FakeFirestoreDocRef
  attr_reader :path

  def initialize store, path
    @store = store
    @path = path
  end

  def get
    raw = @store.documents[@path]
    FakeFirestoreSnapshot.new(raw ? symbolize_value(raw) : nil)
  end

  def set data, merge: false
    normalized = stringify_value data
    @store.documents[@path] =
      if merge && @store.documents.key?(@path)
        @store.documents[@path].merge normalized
      else
        normalized
      end
  end

  def delete
    @store.documents.delete @path
  end

  private

  def symbolize_value value
    case value
    when Hash
      result = {}
      value.each { |k, v| result[k.to_sym] = symbolize_value v }
      result
    when Array
      value.map { |el| symbolize_value el }
    else
      value
    end
  end

  def stringify_value value
    case value
    when Hash
      result = {}
      value.each { |k, v| result[k.to_s] = stringify_value v }
      result
    when Array
      value.map { |el| stringify_value el }
    else
      value
    end
  end
end

class FakeFirestoreCollection
  def initialize store, name
    @store = store
    @name = name
  end

  def doc document_path
    full_path = "#{@name}/#{document_path}"
    segments = full_path.split "/", -1
    if segments.empty? || segments.size.odd? || segments.any?(&:empty?)
      raise ArgumentError, "A document must have an even number of path elements"
    end
    FakeFirestoreDocRef.new @store, full_path
  end
end

class FakeFirestore
  attr_reader :documents

  def initialize
    @documents = {}
  end

  def col name
    FakeFirestoreCollection.new self, name
  end
end

describe "sessions app" do
  include Rack::Test::Methods

  before do
    @fake_firestore = FakeFirestore.new
    Sinatra::Application.instance_variable_set :@prototype, nil
    @app = nil
  end

  def app
    @app ||= Google::Cloud::Firestore.stub :new, @fake_firestore do
      Sinatra::Application.prototype
    end
  end

  def extract_cookie_sid set_cookie_header
    match = set_cookie_header.to_s.match(/rack\.session=([^;]+)/)
    match ? match[1] : nil
  end

  it "displays a greeting and increments views across requests" do
    get "/"
    assert_equal 200, last_response.status
    assert_match(/\A<h1>1 views for ".*"<\/h1>\z/, last_response.body)
    first_greeting = last_response.body[/views for ("[^"]+")/, 1]

    4.times do |idx|
      get "/"
      assert_equal 200, last_response.status
      assert_includes last_response.body, "#{idx + 2} views for #{first_greeting}"
    end
  end

  it "sets HttpOnly and SameSite=Lax cookie flags and hashes Firestore document IDs" do
    get "/"
    set_cookie = last_response.headers["Set-Cookie"]
    public_sid = extract_cookie_sid set_cookie

    refute_nil public_sid
    assert_includes set_cookie, "HttpOnly"
    assert_includes set_cookie, "SameSite=Lax"

    expected_doc_path = "sessions/2::#{Digest::SHA256.hexdigest public_sid}"
    assert_equal [expected_doc_path], @fake_firestore.documents.keys
    refute_includes @fake_firestore.documents.keys, "sessions/#{public_sid}"
  end

  it "sets Secure cookie attribute when mounted with secure: true over HTTPS" do
    secure_app = Google::Cloud::Firestore.stub :new, @fake_firestore do
      Rack::Session::FirestoreSession.new(
        lambda { |env|
          env["rack.session"][:views] = 1
          [200, { "Content-Type" => "text/plain" }, ["ok"]]
        },
        httponly: true,
        same_site: :lax,
        secure: true
      )
    end

    env = Rack::MockRequest.env_for "https://example.org/"
    _status, headers, _body = secure_app.call env
    assert_match(/;\s*secure/i, headers["Set-Cookie"].to_s)
  end

  it "rejects unauthenticated client-chosen session IDs (session fixation)" do
    set_cookie "rack.session=ATTACKER_CHOSEN_SID"
    get "/"

    assert_equal 200, last_response.status
    new_sid = extract_cookie_sid last_response.headers["Set-Cookie"]
    refute_nil new_sid
    refute_equal "ATTACKER_CHOSEN_SID", new_sid
    refute_includes @fake_firestore.documents.keys, "sessions/ATTACKER_CHOSEN_SID"
    attacker_hash = "sessions/2::#{Digest::SHA256.hexdigest 'ATTACKER_CHOSEN_SID'}"
    refute_includes @fake_firestore.documents.keys, attacker_hash
  end

  it "rejects replay of a leaked Firestore private_id document key as a cookie" do
    get "/"
    victim_greeting = last_response.body[/views for ("[^"]+")/, 1]
    get "/"
    assert_includes last_response.body, "2 views for #{victim_greeting}"

    leaked_private_id = @fake_firestore.documents.keys.first.sub "sessions/", ""
    clear_cookies
    set_cookie "rack.session=#{leaked_private_id}"
    get "/"

    assert_match(/\A<h1>1 views for /, last_response.body)
    assert_equal 2, @fake_firestore.documents.size
  end

  it "handles slash path-traversal and empty cookies safely without escaping sessions" do
    ["a/subcol/b", "a/b", ""].each do |malicious_cookie|
      clear_cookies
      set_cookie "rack.session=#{malicious_cookie}"
      get "/"

      assert_equal 200, last_response.status
      @fake_firestore.documents.each_key do |path|
        assert_match(/\Asessions\/2::[0-9a-f]{64}\z/, path)
      end
    end
  end

  it "overwrites deleted session keys without merge: true and honors drop: true" do
    store = Google::Cloud::Firestore.stub :new, @fake_firestore do
      Rack::Session::FirestoreSession.new ->(_env) { [200, {}, ["ok"]] }
    end

    sid, initial = store.find_session nil, nil
    assert_equal({}, initial)

    store.write_session nil, sid, { "user_id" => "u1", "tags" => [{ "role" => "admin" }] }, {}
    _sid, loaded = store.find_session nil, sid
    assert_equal({ "user_id" => "u1", "tags" => [{ "role" => "admin" }] }, loaded)

    store.write_session nil, sid, { "tags" => [{ "role" => "viewer" }] }, {}
    _sid, after_delete = store.find_session nil, sid
    assert_equal({ "tags" => [{ "role" => "viewer" }] }, after_delete)
    refute_includes after_delete.keys, "user_id"

    dropped_result = store.delete_session nil, sid, { drop: true }
    assert_nil dropped_result
    assert_empty @fake_firestore.documents
  end
end
