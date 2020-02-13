require_relative "helper"
require_relative "../iam.rb"

describe "IAM Snippets" do
  parallelize_me!

  let :bucket do
    create_bucket_helper "ruby_storage_sample_#{SecureRandom.hex}"
  end

  let(:role)                  { "roles/storage.admin" }
  let(:member)                { "user:test@test.com" }

  after do
    delete_bucket_helper bucket.name
  end

  describe "view_bucket_iam_members" do
    it "puts the members for each IAM role" do
      bucket.policy do |policy|
        policy.add role, member
      end

      out, _err = capture_io do
        view_bucket_iam_members bucket_name: bucket.name
      end

      assert_includes out, "Role: #{role}"
      assert_includes out, member
    end
  end

  describe "add_bucket_iam_member" do
    it "adds an IAM member" do
      assert_output "Added #{member} with role #{role} to #{bucket.name}\n" do
        add_bucket_iam_member bucket_name: bucket.name,
                              role:        role,
                              member:      member
      end

      assert bucket.policy.roles.any? do |p_role, p_members|
        p_role == role && p_members.includes?(member)
      end
    end
  end

  describe "remove_bucket_iam_member" do
    it "removes an IAM member" do
      assert_output "Removed #{member} with role #{role} from #{bucket.name}\n" do
        remove_bucket_iam_member bucket_name: bucket.name,
                                 role:        role,
                                 member:      member
      end

      refute bucket.policy.roles.none? do |p_role, p_members|
        p_role == role && p_members.includes?(member)
      end
    end
  end
end
