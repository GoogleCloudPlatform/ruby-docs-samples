desc "Run Kokoro tests"

include :exec, e: true
include :fileutils
include :terminal, styled: true

def run
  run_setup
  run_tests
  report_results
  exit 1 unless @failures.empty?
ensure
  run_cleanup
end

####
# Toplevel steps
####

def run_setup
  @failures = []
  @project = ""
  @kill_on_cleanup = []
  gimme_proj
  setup_env
  setup_workarounds
  list_products
  filter_by_ruby_versions
  filter_by_changed_paths if presubmit?
  start_app_engine_services
  start_cloud_sql_services
end

def run_tests
  configure_exec e: false
  test_globals
  @products.each do |dir|
    test_product dir
  end
end

def report_results
  if @failures.empty?
    puts "ALL TESTS PASSED!", :green, :bold
    return
  end
  puts "Failures:", :red, :bold
  @failures.each do |failure|
    puts failure, :red, :bold
  end
  puts "Search these logs for the red test names listed above to see details."
  unless presubmit?
    chmod "+x", "#{gfile_dir}/linux_amd64/flakybot"
    exec ["#{gfile_dir}/linux_amd64/flakybot"]
  end
end

def run_cleanup
  exec ["gimmeproj", "-project", "cloud-samples-ruby-test-kokoro", "done", @project] unless @project.empty?
  @kill_on_cleanup.each do |process|
    process.kill "SIGKILL"
  end
end

####
# Steps related to setup
####

##
# Get a project from the project pool.
#
def gimme_proj
  # These credentials are used by gimmeproj
  ENV["GOOGLE_APPLICATION_CREDENTIALS"] = "#{keystore_dir}/71386_kokoro-cloud-samples-ruby-test-0"
  puts "Installing Gimmeproj", :bold
  Dir.chdir "/tmp" do
    exec ["wget", "-q", "https://storage.googleapis.com/gimme-proj/linux_amd64/gimmeproj"]
    mv "gimmeproj", "/bin/gimmeproj"
  end
  chmod "+x", "/bin/gimmeproj"
  exec ["/bin/gimmeproj", "version"]
  puts "Getting a project", :bold
  @project = capture(["/bin/gimmeproj", "-project", "cloud-samples-ruby-test-kokoro", "lease", "60m"]).strip
  error "gimmeproj lease failed" if @project.empty?
  puts "Running tests in project #{@project}", :bold
end

##
# Set up most environment variables (projets and credentials) for tests
#
def setup_env
  # Primary project
  ENV["GOOGLE_CLOUD_PROJECT"] = @project
  ENV["GOOGLE_APPLICATION_CREDENTIALS"] = "#{keystore_dir}/71386_kokoro-#{@project}"

  # Secondary project
  ENV["GOOGLE_CLOUD_PROJECT_SECONDARY"] = "cloud-samples-ruby-test-second"
  ENV["GOOGLE_APPLICATION_CREDENTIALS_SECONDARY"] = "#{gfile_dir}/cloud-samples-ruby-test-second-ede32e88c59c.json"

  # Special project for firestore
  ENV["FIRESTORE_PROJECT_ID"] = "ruby-firestore-ci"
  ENV["E2E_GOOGLE_CLOUD_PROJECT"] = "cloud-samples-ruby-test-kokoro"

  # Database names mirror the main project name
  ENV["POSTGRES_DATABASE"] = ENV["MYSQL_DATABASE"] = @project.tr "-", "_"

  # Storage bucket names mirror the main projecct name
  ENV["GOOGLE_CLOUD_STORAGE_BUCKET"] = "#{@project}-cloud-samples-ruby-bucket"
  ENV["ALTERNATE_GOOGLE_CLOUD_STORAGE_BUCKET"] = "#{@project}-cloud-samples-ruby-bucket-alt"

  # Single project for spanner
  ENV["GOOGLE_CLOUD_SPANNER_TEST_INSTANCE"] = "ruby-test-instance"
  ENV["GOOGLE_CLOUD_SPANNER_PROJECT"] = "cloud-samples-ruby-test-0"

  # Used by E2E tests
  ENV["BUILD_ID"] = @build_id = assert_env("KOKORO_BUILD_ID")[-10..]
end

##
# A few miscellaneous workarounds for weird issues
#
def setup_workarounds
  # Temporary workaround for a known bundler+docker issue:
  # https://github.com/bundler/bundler/issues/6154
  ENV["BUNDLE_GEMFILE"] = ""

  # Workaround for new security feature in git 2.35.2 (see https://github.blog/2022-04-12-git-security-vulnerability-announced/)
  exec ["git", "config", "--global", "--add", "safe.directory", context_directory]
end

##
# Find all directories with tests, and set them in the `@products` variable.
#
def list_products
  # Paths that look like tests for us to run but aren't.
  # Currently, we include the rails tests for the run/rails tutorial.
  omit_list = ["run/rails/test"]
  @products = []
  (Dir.glob("*/Gemfile") + Dir.glob("*/*/Gemfile")).each do |gemfile|
    dir = File.dirname gemfile
    if (File.directory?("#{dir}/test") && !omit_list.include?("#{dir}/test")) ||
       (File.directory?("#{dir}/spec") && !omit_list.include?("#{dir}/spec")) ||
       (File.executable?("#{dir}/bin/run_tests") && !omit_list.include?("#{dir}/bin/run_tests"))
      @products << dir
    end
  end
  puts "Found #{@products.size} total test directories"
end

##
# Filter out products whose tests will not run on the current Ruby version
#
def filter_by_ruby_versions
  unless newest_ruby?
    # Spanner tests are too slow. Run only on newest.
    @products.delete "spanner"
    # run/rails uses Rails 7 and requires newest Ruby.
    @products.delete "run/rails"
  end
  if newest_ruby?
    # getting-started uses an old Rails and is incompatible with newest.
    @products.delete_if { |dir| dir.start_with? "getting-started/" }
    # appengine tests are slow and some use an old Rails. Run only on oldest.
    @products.delete_if { |dir| dir.start_with? "appengine/" }
  end
end

##
# Filter out products that have no changed files. This method should be called
# in the presubmit case but not the nightly case.
#
def filter_by_changed_paths
  base_sha = capture(["git", "merge-base", "HEAD", "main"]).strip
  changed_paths = capture(["git", "--no-pager", "diff", "--name-only", "HEAD", base_sha]).split("\n")
  puts "Changed paths:", :bold
  changed_paths.each { |changed_path| puts changed_path }
  infra_dirs = ["spec/", ".kokoro/", ".toys/"]
  if changed_paths.any? { |changed_path| infra_dirs.any? { |dir| changed_path.start_with? dir } }
    # Spanner takes a long time, so omit it when testing infrastructure changes
    @products.delete "spanner"
    puts "Test drivers may have changed; running all tests except spanner.", :bold
    return
  end
  puts "Filtering tests based on what has changed...", :bold
  @products.select! do |product_dir|
    keep = changed_paths.any? { |changed_path| changed_path.start_with? "#{product_dir}/" }
    if keep
      puts "Keeping #{product_dir}"
    else
      puts "Omitting #{product_dir}"
    end
    keep
  end
end

##
# Install and run tools needed for app engine and cloud run tests.
#
def start_app_engine_services
  return unless @products.any? { |dir| dir.start_with?("run/") || dir.start_with?("appengine/") }
  puts "Initializing app engine and cloud run tools", :bold
  install_gcloud_cli
  process = exec ["/bin/cloud_sql_proxy", "-dir=/cloudsql", "-credential_file=#{gac_path}"],
                 background: true, out: :inherit
  ENV["CLOUD_SQL_PROXY_PROCESS_ID"] = process.pid.to_s
  @kill_on_cleanup << process
  start_memcached
end

##
# Launch cloud sql proxy instances for cloud-sql tests
#
def start_cloud_sql_services
  if @products.include? "cloud-sql/mysql"
    install_cloud_sql_proxy
    puts "Starting Cloud SQL Proxy for MySQL", :bold
    connection_name = assert_env "MYSQL_INSTANCE_CONNECTION_NAME"
    process = exec ["/bin/cloud_sql_proxy",
                    "-instances=#{connection_name}=tcp:3306,#{connection_name}",
                    "-dir=/cloudsql", "-credential_file=#{gac_path}"],
                   background: true, out: :inherit
    ENV["MYSQL_CLOUD_SQL_PROXY_PROCESS_ID"] = process.pid.to_s
    @kill_on_cleanup << process
  end
  if @products.include? "cloud-sql/postgres"
    install_cloud_sql_proxy
    puts "Starting Cloud SQL Proxy for Postgres", :bold
    connection_name = assert_env "POSTGRES_INSTANCE_CONNECTION_NAME"
    process = exec ["/bin/cloud_sql_proxy",
                    "-instances=#{connection_name}=tcp:5432,#{connection_name}",
                    "-dir=/cloudsql", "-credential_file=#{gac_path}"],
                   background: true, out: :inherit
    ENV["POSTGRES_CLOUD_SQL_PROXY_PROCESS_ID"] = process.pid.to_s
    @kill_on_cleanup << process
  end
  if @products.include? "cloud-sql/postgres"
    install_cloud_sql_proxy
    puts "Starting Cloud SQL Proxy for SQL Server", :bold
    connection_name = assert_env "SQLSERVER_INSTANCE_CONNECTION_NAME"
    process = exec ["/bin/cloud_sql_proxy",
                    "-instances=#{connection_name}=tcp:1433",
                    "-credential_file=#{gac_path}"],
                   background: true, out: :inherit
    ENV["SQLSERVER_CLOUD_SQL_PROXY_PROCESS_ID"] = process.pid.to_s
    @kill_on_cleanup << process
  end
end

##
# Start memcached.
# TODO: This was used previously for an appengine/memcache test, but that
# samples seems not to exist anymore, so this may not be needed.
#
def start_memcached
  exec ["service", "memcached", "start"]
end

##
# Download and install cloud_sql_proxy
#
def install_cloud_sql_proxy
  return if defined? @cloud_sql_proxy_installed
  puts "Installing Cloud SQL Proxy", :bold
  Dir.chdir "/tmp" do
    exec ["wget", "-q", "https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64"]
    mv "cloud_sql_proxy.linux.amd64", "/bin/cloud_sql_proxy"
  end
  chmod "+x", "/bin/cloud_sql_proxy"
  mkdir "/cloudsql"
  chmod 0777, "/cloudsql"
  @cloud_sql_proxy_installed = true
end

##
# Installs the gcloud tool
#
def install_gcloud_cli
  return if defined? @gcloud_cli_installed
  puts "Installing gcloud cli", :bold
  Dir.chdir "/tmp" do
    exec ["wget", "-q", "https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz"]
    exec ["tar", "xzf", "google-cloud-sdk.tar.gz"]
    mv "google-cloud-sdk", "/google-cloud-sdk"
  end
  exec ["/google-cloud-sdk/install.sh",
        "--usage-reporting", "false",
        "--path-update", "false",
        "--command-completion", "false"]
  ENV["PATH"] = "#{ENV['PATH']}:/google-cloud-sdk/bin"
  exec ["gcloud", "-q", "components", "update"]
  exec ["gcloud", "config", "set", "disable_prompts", "True"]
  exec ["gcloud", "config", "set", "project", assert_env("E2E_GOOGLE_CLOUD_PROJECT")]
  exec ["gcloud", "config", "set", "app/promote_by_default",  "false"]
  exec ["gcloud", "auth", "activate-service-account", "--key-file", gac_path]
  exec ["gcloud", "info"]
  @gcloud_cli_installed = true
end

####
# Steps related to test running
####

##
# Run global bundle and global rubocop
#
def test_globals
  start_time = Time.now.to_i
  if test_exec "BUNDLE:global", ["bundle", "update"]
    test_exec "RUBOCOP:global", ["bundle", "exec", "rubocop"]
  end
  finish_time = Time.now.to_i
  puts "Global tests took #{finish_time - start_time} seconds"
end

##
# Run tests in the given directory.
#
def test_product dir
  is_e2e = !presubmit? && newest_ruby? || dir.start_with?("run/") || dir.start_with?("appengine/")
  ENV["E2E"] = is_e2e.to_s
  ENV["TEST_DIR"] = dir
  start_time = Time.now.to_i
  Dir.chdir dir do
    if test_exec "BUNDLE:#{dir}", ["bundle", "update"]
      if File.executable? "bin/run_tests"
        test_exec "RUN_TESTS:#{dir}", ["bin/run_tests"]
      elsif File.directory? "spec"
        test_rspec dir
      elsif File.directory? "test"
        test_minitest dir
      else
        test_exec "UNKNOWN_TESTER:#{dir}"
      end
    end
  end
  exec ["bundle", "exec", "ruby", "spec/e2e_cleanup.rb", dir, @build_id] if is_e2e
  finish_time = Time.now.to_i
  puts "Tests for #{dir} took #{finish_time - start_time} seconds"
end

##
# Run a rspec-based test.
#
def test_rspec dir
  cmd = ["bundle", "exec", "rspec", "--format", "documentation"]
  cmd += ["--format", "RspecJunitFormatter", "--out", "sponge_log.xml"] unless presubmit?
  test_exec "SPEC:#{dir}", cmd
end

##
# Run a minitest-based test.
#
def test_minitest dir
  test_exec "MINITEST:#{dir}" do
    test_files = Dir.glob("test/**/*_test.rb")
    args = ["-Itest", "-w"]
    args += ["-", "--junit", "--junit-filename=sponge_log.xml"] unless presubmit?
    exec_ruby args, in: :controller do |controller|
      controller.in.puts "require 'bundler/setup'"
      controller.in.puts "require 'minitest/autorun'"
      test_files.each do |path|
        controller.in.puts "load '#{path}'"
      end
    end
  end
end

##
# Perform a test and report its result.
#
def test_exec name, command = nil
  puts "**** RUNNING: #{name} ...", :cyan, :bold
  result =
    if command
      exec(command)
    elsif block_given?
      yield
    end
  if result&.success?
    puts "**** PASSED: #{name}", :green, :bold
    true
  else
    puts "**** FAILURE: #{name}", :red, :bold
    @failures << name
    false
  end
end

####
# Helpers
####

def keystore_dir
  @keystore_dir ||= assert_env "KOKORO_KEYSTORE_DIR"
end

def gfile_dir
  @gfile_dir ||= assert_env "KOKORO_GFILE_DIR"
end

def gac_path
  @gac_path ||= ENV["GOOGLE_APPLICATION_CREDENTIALS"]
end

def presubmit?
  unless defined? @is_presubmit
    @is_presubmit = (/system-tests/ =~ assert_env("KOKORO_BUILD_ARTIFACTS_SUBDIR")).nil?
  end
  @is_presubmit
end

def newest_ruby?
  unless defined? @is_newest_ruby
    @is_newest_ruby = assert_env("KOKORO_RUBY_VERSION") == "newest"
  end
  @is_newest_ruby
end

def assert_env name, allow_empty: false
  val = ENV[name]
  error "Environment variable #{name} is not set" if val.nil?
  error "Environment variable #{name} is empty" if !allow_empty && val.empty?
  val
end

def error msg
  puts msg, :red, :bold
  exit 1
end
