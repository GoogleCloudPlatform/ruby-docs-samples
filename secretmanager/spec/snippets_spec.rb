# Copyright 2020 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "uri"

require_relative "spec_helper"
require_relative "../snippets"

describe "Secret Manager Snippets" do
  let(:client) { Google::Cloud::SecretManager.secret_manager_service }
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }

  let(:secret_id) { "ruby-quickstart-#{(Time.now.to_f*1000).to_i}" }
  let(:secret_name) { "projects/#{project_id}/secrets/#{secret_id}" }

  let(:secret) do
    client.create_secret(
      parent:    "projects/#{project_id}",
      secret_id: secret_id,
      secret:    {
        replication: {
          automatic: {}
        }
      }
    )
  end

  let(:secret_version) do
    client.add_secret_version(
      parent:  secret.name,
      payload: {
        data: "hello world!"
      }
    )
  end

  let(:version_id) { URI(secret_version.name).path.split("/").last }
  let(:version_name) { "projects/#{project_id}/secrets/#{secret_id}/versions/#{version_id}" }

  after do
    begin
      client.delete_secret name: secret_name
    rescue Google::Cloud::NotFoundError; end
  end

  describe "#access_secret_version" do
    it "accesses the version" do
      expect {
        version = access_secret_version(
          project_id: project_id,
          secret_id:  secret_id,
          version_id: version_id
        )

        expect(version).to be
        expect(version.name).to include(secret_id)
        expect(version.payload.data).to eq("hello world!")
      }.to output(/Plaintext: hello world!/).to_stdout
    end
  end

  describe "#add_secret_version" do
    it "adds a secret version" do
      o_list = client.list_secret_versions(parent: secret.name).to_a
      expect(o_list).to be_empty

      expect {
        version = add_secret_version(
          project_id: project_id,
          secret_id:  secret_id
        )

        n_list = client.list_secret_versions(parent: secret.name).to_a
        expect(n_list).to include(version)
      }.to output(/Added secret version:/).to_stdout
    end
  end

  describe "#create_secret" do
    it "creates a secret" do
      expect {
        secret = create_secret(
          project_id: project_id,
          secret_id:  secret_id
        )

        expect(secret).to be
        expect(secret.name).to include(secret_id)
      }.to output(/Created secret/).to_stdout
    end
  end

  describe "#delete_secret" do
    it "deletes the secret" do
      expect(secret).to be

      expect {
        delete_secret(
          project_id: project_id,
          secret_id:  secret_id
        )
      }.to output(/Deleted secret/).to_stdout

      expect {
        client.get_secret name: secret_name
      }.to raise_error(Google::Cloud::NotFoundError)
    end
  end

  describe "#destroy_secret_version" do
    it "destroys the secret version" do
      expect(secret_version).to be

      expect {
        destroy_secret_version(
          project_id: project_id,
          secret_id:  secret_id,
          version_id: version_id
        )
      }.to output(/Destroyed secret version/).to_stdout

      n_version = client.get_secret_version name: version_name
      expect(n_version).to be
      expect(n_version.state.to_s.downcase).to eq("destroyed")
    end
  end

  describe "#disable_secret_version" do
    it "disables the secret version" do
      expect(secret_version).to be

      expect {
        disable_secret_version(
          project_id: project_id,
          secret_id:  secret_id,
          version_id: version_id
        )
      }.to output(/Disabled secret version/).to_stdout

      n_version = client.get_secret_version name: version_name
      expect(n_version).to be
      expect(n_version.state.to_s.downcase).to eq("disabled")
    end
  end

  describe "#enable_secret_version" do
    it "enables the secret version" do
      expect(secret_version).to be
      client.disable_secret_version name: version_name

      expect {
        enable_secret_version(
          project_id: project_id,
          secret_id:  secret_id,
          version_id: version_id
        )
      }.to output(/Enabled secret version/).to_stdout

      n_version = client.get_secret_version name: version_name
      expect(n_version).to be
      expect(n_version.state.to_s.downcase).to eq("enabled")
    end
  end

  describe "#get_secret" do
    it "gets the secret" do
      expect(secret).to be
      expect {
        n_secret = get_secret(
          project_id: project_id,
          secret_id:  secret_id
        )

        expect(n_secret).to be
        expect(n_secret.name).to eq(secret.name)
      }.to output(/Got secret/).to_stdout
    end
  end

  describe "#get_secret_version" do
    it "gets the secret version" do
      expect(secret_version).to be
      expect {
        n_version = get_secret_version(
          project_id: project_id,
          secret_id:  secret_id,
          version_id: version_id
        )

        expect(n_version).to be
        expect(n_version.name).to eq(secret_version.name)
      }.to output(/Got secret version/).to_stdout
    end
  end

  describe "#list_secret_versions" do
    it "lists the secret versions" do
      expect(secret).to be
      expect(secret_version).to be

      expect {
        list_secret_versions(
          project_id: project_id,
          secret_id:  secret_id
        )
      }.to output(/Got secret version(.+)#{version_id}/).to_stdout
    end
  end

  describe "#list_secrets" do
    it "lists the secrets" do
      expect(secret).to be

      expect {
        list_secrets project_id: project_id
      }.to output(/Got secret(.+)#{secret_id}/).to_stdout
    end
  end

  describe "#update_secret" do
    it "updates the secret" do
      expect(secret).to be

      expect {
        n_secret = update_secret(
          project_id: project_id,
          secret_id:  secret_id
        )

        expect(n_secret).to be
        expect(n_secret.labels).to have_key("secretmanager")
        expect(n_secret.labels["secretmanager"]).to eq("rocks")
      }.to output(/Updated secret/).to_stdout
    end
  end
end
