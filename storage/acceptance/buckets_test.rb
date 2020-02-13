require_relative "helper"
require_relative "../buckets.rb"

describe "Buckets Snippets" do
  parallelize_me!

  let(:storage_client) { Google::Cloud::Storage.new }

  let :bucket do
    create_bucket_helper "ruby_storage_sample_#{SecureRandom.hex}"
  end

  let :secondary_bucket do
    create_bucket_helper "ruby_storage_sample_#{SecureRandom.hex}_secondary"
  end

  after do
    delete_bucket_helper bucket.name
    delete_bucket_helper secondary_bucket.name
  end

  describe "list_buckets" do
    it "puts the buckets for a GCP project" do
      bucket
      secondary_bucket

      out, _err = capture_io do
        list_buckets
      end

      assert_includes out, bucket.name
      assert_includes out, secondary_bucket.name
    end
  end

  describe "list_bucket_details" do
    it "puts the details of a storage bucket" do
      out, _err = capture_io do
        list_bucket_details bucket_name: bucket.name
      end

      assert_includes out, bucket.name
    end
  end

  describe "disable_requester_pays" do
    it "disables requester_pays for a storage bucket" do
      bucket.requester_pays = true

      assert_output "Requester pays has been disabled for #{bucket.name}\n" do
        disable_requester_pays bucket_name: bucket.name
      end
      bucket.refresh!
      refute bucket.requester_pays?
    end
  end

  describe "enable_requester_pays" do
    it "enables requester_pays for a storage bucket" do
      bucket.requester_pays = false

      assert_output "Requester pays has been enabled for #{bucket.name}\n" do
        enable_requester_pays bucket_name: bucket.name
      end
      bucket.refresh!
      assert bucket.requester_pays?
    end
  end

  describe "get_requester_pays_status" do
    it "displays the status of requester_pays for a storage bucket" do
      bucket.requester_pays = false

      assert_output "Requester Pays is disabled for #{bucket.name}\n" do
        get_requester_pays_status bucket_name: bucket.name
      end

      bucket.requester_pays = true
      assert_output "Requester Pays is enabled for #{bucket.name}\n" do
        get_requester_pays_status bucket_name: bucket.name
      end
    end
  end

  describe "disable_uniform_bucket_level_access" do
    it "disables uniform bucket level access for a storage bucket" do
      bucket.uniform_bucket_level_access = true

      assert_output "Uniform bucket-level access was disabled for #{bucket.name}.\n" do
        disable_uniform_bucket_level_access bucket_name: bucket.name
      end

      bucket.refresh!
      refute bucket.uniform_bucket_level_access?
    end
  end

  describe "enable_uniform_bucket_level_access" do
    it "enables uniform bucket level access for a storage bucket" do
      bucket.uniform_bucket_level_access = false

      assert_output "Uniform bucket-level access was enabled for #{bucket.name}.\n" do
        enable_uniform_bucket_level_access bucket_name: bucket.name
      end

      bucket.refresh!
      assert bucket.uniform_bucket_level_access?
    end
  end

  describe "get_uniform_bucket_level_access" do
    it "displays the status of uniform bucket level access for a storage bucket" do
      bucket.uniform_bucket_level_access = false

      assert_output "Uniform bucket-level access is disabled for #{bucket.name}.\n" do
        get_uniform_bucket_level_access bucket_name: bucket.name
      end
      refute bucket.uniform_bucket_level_access?

      bucket.uniform_bucket_level_access = true

      assert_output "Uniform bucket-level access is enabled for #{bucket.name}.\nBucket "\
                    "will be locked on #{bucket.uniform_bucket_level_access_locked_at}.\n" do
        get_uniform_bucket_level_access bucket_name: bucket.name
      end
      assert bucket.uniform_bucket_level_access?
    end
  end
end
