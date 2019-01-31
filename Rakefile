LATEST_RUBY                              = "2.5.3"

GOOGLE_CLOUD_PROJECT                     = "GOOGLE_CLOUD_PROJECT"
GOOGLE_APPLICATION_CREDENTIALS           = "GOOGLE_APPLICATION_CREDENTIALS"
GOOGLE_CLOUD_STORAGE_BUCKET              = "GOOGLE_CLOUD_STORAGE_BUCKET"
ALTERNATE_GOOGLE_CLOUD_STORAGE_BUCKET    = "ALTERNATE_GOOGLE_CLOUD_STORAGE_BUCKET"
GOOGLE_CLOUD_PROJECT_SECONDARY           = "GOOGLE_CLOUD_PROJECT_SECONDARY"
GOOGLE_APPLICATION_CREDENTIALS_SECONDARY = "GOOGLE_APPLICATION_CREDENTIALS_SECONDARY"
GOOGLE_CLOUD_KMS_KEY_NAME                = "GOOGLE_CLOUD_KMS_KEY_NAME"
GOOGLE_CLOUD_KMS_KEY_RING                = "GOOGLE_CLOUD_KMS_KEY_RING"
# KOKORO_KEYSTORE_DIR                      = "KOKORO_KEYSTORE_DIR"
KOKORO_GFILE_DIR                         = "KOKORO_GFILE_DIR"
KOKORO_BUILD_ID                          = "KOKORO_BUILD_ID"
REPO_DIRECTORY                           = "REPO_DIRECTORY"

task :test do
  verify_env_vars
  spec_list.each do |dir|
    Dir.chdir dir do
      Bundler.with_clean_env do
        header_2 "Testing #{dir.split('ruby-docs-samples/').last}"
        sh "bundle update"
        sh "bundle exec rspec"
      end
    end
  end
  sh "bundle exec rubocop"
end

namespace :kokoro do
  exit_code = 0

  desc "Generate configs for kokoro"
  task :build do
    generate_kokoro_configs
  end

  task :load_env_vars do
    require "json"

    filename = "#{ENV[KOKORO_GFILE_DIR]}/secrets.json"
    env_vars = JSON.parse File.read(filename)
    env_vars.each { |k, v| ENV[k] = v.sub "$#{KOKORO_GFILE_DIR}", ENV[KOKORO_GFILE_DIR] }
    # env_vars.each { |k, v| ENV[k] = v.sub "$#{KOKORO_KEYSTORE_DIR}", ENV[KOKORO_KEYSTORE_DIR] }
    verify_env_vars
  end

  task :presubmit do
    header_2 ENV["JOB_TYPE"]
    # exit_code = [exit_code, (run_with_timeout "bundle exec rubocop")].max
    # if updated_specs.any? { |spec| spec.include? ENV["SPEC"] }
      Dir.chdir ENV["SPEC"] do
        Bundler.with_clean_env do
          Rake::Task["kokoro:load_env_vars"].invoke
          header "Using Ruby - #{RUBY_VERSION}"
          sh "bundle update"
          exit_code = [exit_code, (run_with_timeout "bundle exec rspec", 2700)].max
        end
      end
    # end

    exit exit_code
  end

  task :continuous do
    header_2 ENV["JOB_TYPE"]
    # exit_code = [exit_code, (run_with_timeout "bundle exec rubocop")].max
    updated = updated_specs.any? { |spec| spec.include? ENV["SPEC"] }
    updated_specs.each { |gem| header_2 "#{gem} has been updated" }
    Dir.chdir ENV["SPEC"] do
      Bundler.with_clean_env do
        Rake::Task["kokoro:load_env_vars"].invoke
        header "Using Ruby - #{RUBY_VERSION}"
        unless RUBY_VERSION == LATEST_RUBY || updated
          header "Directory Unchanged - Skipping Tests"
        else
          msg = ["Running Tests for #{ENV['SPEC']}"]
          msg.unshift "Using Latest Ruby" if RUBY_VERSION == LATEST_RUBY
          msg.unshift "Directory Updated" if updated
          header msg.join " - "
          sh "bundle update"
          Rake::Task["kokoro:gcloud"].invoke
          exit_code = [exit_code, (run_with_timeout "bundle exec rspec", 3600)].max
          sh "bundle exec ruby #{ENV[REPO_DIRECTORY]}/spec/e2e_cleanup.rb #{ENV["SPEC"]}"\
             " #{ENV[KOKORO_BUILD_ID][-4..-1]}"
        end
      end
    end
    exit exit_code
  end

  task :nightly do
    header_2 ENV["JOB_TYPE"]
    # exit_code = [exit_code, (run_with_timeout "bundle exec rubocop")].max
    Dir.chdir ENV["SPEC"] do
      Bundler.with_clean_env do
        Rake::Task["kokoro:load_env_vars"].invoke
        header "Using Ruby - #{RUBY_VERSION}"
        sh "bundle update"
        exit_code = [exit_code, (run_with_timeout "bundle exec rspec", 3600)].max
        sh "bundle exec ruby #{ENV[REPO_DIRECTORY]}/spec/e2e_cleanup.rb #{ENV["SPEC"]}"\
           " #{ENV[KOKORO_BUILD_ID][-4..-1]}"
      end
    end
  end

  task :gcloud do
    header_2 "Setting up the Cloud SDK"
    Rake::Task["kokoro:load_env_vars"].invoke
    `gcloud config set disable_prompts True`
    `gcloud config set project #{ENV[E2E_GOOGLE_CLOUD_PROJECT]}`
    `gcloud config set app/promote_by_default false`
    `gcloud auth activate-service-account --key-file #{ENV[GOOGLE_APPLICATION_CREDENTIALS]}`
    puts `gcloud info`
  end
end

def specs
  Dir.glob("**/spec/").reject { |dir| dir == "spec/" }.map do |dir|
    File.expand_path "..", dir
  end
end

def updated_specs commit = true
  comparison = "HEAD $(git merge-base HEAD master)"
  comparison = "HEAD^ HEAD" if commit
  updated_directories = `git --no-pager diff --name-only #{comparison} | grep "/" | cut -d/ -f1 | sort | uniq || true`
                        .split("\n").reject { |dir| dir.include? "appengine" }
  updated_directories += 
    `git --no-pager diff --name-only #{comparison} | grep "/appengine" | cut -d/ -f1 | sort | uniq || true`
    .split "\n"
  specs.select { |spec| updated_directories.include? spec }
end

def run_with_timeout command, timeout = 0
  require "timeout"

  job = Process.spawn command
  begin
    Timeout.timeout(timeout) { Process.wait job }
    return $?.exitstatus
  rescue Timeout::Error
    header_2 "TIMEOUT - #{timeout / 60} minute limit exceeded."
    Process.kill "TERM", job
  end
  1
end

def verify_env_vars
  missing_env_vars = [
    GOOGLE_CLOUD_PROJECT, GOOGLE_APPLICATION_CREDENTIALS, GOOGLE_CLOUD_STORAGE_BUCKET,
    ALTERNATE_GOOGLE_CLOUD_STORAGE_BUCKET, GOOGLE_CLOUD_PROJECT_SECONDARY,
    GOOGLE_APPLICATION_CREDENTIALS_SECONDARY, GOOGLE_CLOUD_KMS_KEY_NAME, GOOGLE_CLOUD_KMS_KEY_RING
  ].select { |env_var| ENV[env_var].nil? }
  raise "The following environment variables must be set: #{missing_env_vars.join ", "}" unless missing_env_vars.empty?
end

def header str, token = "#"
  line_length = str.length + 8
  puts ""
  puts token * line_length
  puts "#{token * 3} #{str} #{token * 3}"
  puts token * line_length
  puts ""
end

def header_2 str, token = "#"
  puts "\n#{token * 3} #{str} #{token * 3}\n"
end

def generate_kokoro_configs
  require "fileutils"
  require "erb"

  specs
    .map { |spec| spec.split("ruby-docs-samples/").last }
    .reject { |dir| dir.include? "ruby-docs-samples" }
    .each do |spec|
    name = spec.gsub "/", "-"
    [:linux, :osx].each do |os_version|
      [:presubmit, :continuous, :nightly].each do |build_type|
        # Generate build
        FileUtils.mkdir_p "./.kokoro/#{build_type}/#{os_version}"
        file_path = "./.kokoro/#{build_type}/#{os_version}/#{name}.cfg"
        File.open file_path, "w" do |f|
          config = ERB.new File.read("./.kokoro/templates/#{os_version}.cfg.erb")
          f.write config.result(binding)
        end
      end
    end
  end
end
