# Copyright 2021 Google LLC
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

require "helper"

describe "functions_firebase_reactive" do
  include FunctionsFramework::Testing

  let(:document_name) { "gcf-test/abcde" }
  let(:mock_firestore) { Minitest::Mock.new }
  let(:mock_firestore_doc) { Minitest::Mock.new }

  it "responds to firestore reactive update event" do
    load_temporary "firebase/reactive/app.rb" do
      mock_firestore.expect :doc, mock_firestore_doc, [document_name]
      mock_firestore_doc.expect :set, nil, [{ original: "HELLO" }], merge: false
      firestore_client = FunctionsFramework::Function::LazyGlobal.new(proc { mock_firestore })

      payload = { "value" => { "fields" => { "original" => { "stringValue" => "Hello" } } } }
      event = make_cloud_event payload, subject: "documents/#{document_name}"
      _out, err = capture_subprocess_io do
        call_event "make_upper_case", event, globals: { firestore_client: firestore_client }
      end

      mock_firestore.verify
      mock_firestore_doc.verify
      assert_includes err, "Replacing value: Hello --> HELLO"
    end
  end

  it "does not update again if the input is already upper case" do
    load_temporary "firebase/reactive/app.rb" do
      firestore_client = FunctionsFramework::Function::LazyGlobal.new(proc { raise "Shouldn't get here" })

      payload = { "value" => { "fields" => { "original" => { "stringValue" => "HELLO" } } } }
      event = make_cloud_event payload, subject: "documents/#{document_name}"
      _out, err = capture_subprocess_io do
        call_event "make_upper_case", event, globals: { firestore_client: firestore_client }
      end

      assert_includes err, "Value is already upper-case"
    end
  end
end
