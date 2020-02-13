require_relative "helper"
require_relative "../hmac.rb"

describe "HMAC Snippets" do
  parallelize_me!

  let(:storage_client)        { Google::Cloud::Storage.new }
  let(:project_id)            { storage_client.project }
  let(:service_account_email) { "#{project_id}@appspot.gserviceaccount.com" }

  let :hmac_key do
    hmac_key = storage_client.create_hmac_key service_account_email
    hmac_key
  end

  after do
    delete_hmac_key_helper hmac_key
  end

  describe "list_hmac_keys" do
    it "lists the hmac keys for a GCP project" do
      access_id = hmac_key.access_id

      out, _err = capture_io do
        list_hmac_keys
      end

      assert_includes out, "Service Account Email: #{service_account_email}"
      assert_includes out, "Access ID: #{access_id}"
    end
  end

  describe "create_hmac_key" do
    it "creates an hmac key" do
      out, _err = capture_io do
        create_hmac_key service_account_email: service_account_email
      end
      match = out.match(/Access ID:\s+(.*)\n/)
      access_id = match[1]
      # Raises error if no hmac_key found
      hmac_key = storage_client.hmac_key access_id

      assert_match(/Service Account Email:\s+#{service_account_email}/, out)
    end
  end

  describe "get_hmac_key" do
    it "gets an hmac key from an access_id" do
      access_id = hmac_key.access_id

      out, _err = capture_io do
        get_hmac_key access_id: access_id
      end

      assert_match(/Service Account Email:\s+#{service_account_email}/, out)
    end
  end

  describe "activate_hmac_key" do
    it "activates an hmac key from an access_id" do
      hmac_key.inactive!

      out, _err = capture_io do
        activate_hmac_key access_id: hmac_key.access_id
      end

      assert_match(/Service Account Email:\s+#{service_account_email}/, out)
      hmac_key.refresh!
      assert hmac_key.active?
    end
  end

  describe "deactivate_hmac_key" do
    it "deactivates an hmac key from an access_id" do
      out, _err = capture_io do
        deactivate_hmac_key access_id: hmac_key.access_id
      end

      assert_match(/Service Account Email:\s+#{service_account_email}/, out)
      hmac_key.refresh!
      assert hmac_key.inactive?
    end
  end

  describe "delete_hmac_key" do
    it "deletes an hmac key from an access_id" do
      hmac_key.inactive!
      access_id = hmac_key.access_id

      assert_output "The key is deleted, though it may still appear in Client#hmac_keys results.\n" do
        delete_hmac_key access_id: access_id
      end

      hmac_key.refresh!
      assert hmac_key.deleted?
    end
  end
end
