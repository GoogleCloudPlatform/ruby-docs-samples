require "rake/testtask"

task :test do
  run_tests "test"
end

task :acceptance do
  run_tests "acceptance"
end

def run_tests type
  failed = false
  full_start_time = Time.now

  header "Running on Ruby #{RUBY_VERSION}"
  header "Installing dependencies"
  each_lib do |dir|
    header "Installing bundle in #{dir}"
    sh "bundle update"
  end

  each_lib do |dir|
    start_time = Time.now
    lib = dir.split("ruby-docs-samples/").last
    begin
      header "Running tests for #{lib}"
      test_task dir, type
    rescue
      failed = true
    end
    end_time = Time.now
    header_2 "Tests for #{lib} took #{(end_time - start_time).to_i} seconds"
  end

  full_end_time = Time.now
  header_2 "Tests took a total of #{(full_end_time - full_start_time).to_i} seconds"
  raise "Tests failed" if failed
  header "Tests passed"
end

def each_lib
  dirs.each do |dir|
    Dir.chdir dir do
      Bundler.with_clean_env do
        yield dir
      end
    end
  end
end

def each_gemfile
  gemfiles = Dir.glob("**/Gemfile") - ["Gemfile"]
  gemfiles.map! { |gemfile| File.dirname gemfile }.uniq!
  gemfiles.each do |gemfile|
    yield gemfile
  end
end

def test_task dir, type
  Rake::TestTask.new "#{dir}_#{type}" do |t|
    t.test_files = FileList["#{dir}/#{type}/**/*_test.rb"]
    t.options = "--junit --junit-filename=#{dir}/sponge_log.xml"
    t.warning = false
  end
  Rake::Task["#{dir}_#{type}"].invoke
end

def dirs
  entries = Dir.glob("#{__dir__}/**/*_test.rb").map do |entry|
    File.expand_path "..", File.dirname(entry)
  end
  entries.uniq!
  if RUBY_VERSION.start_with? "2.4"
    entries.delete_if { |dir| dir.include? "/ruby-docs-samples/functions" }
  elsif !RUBY_VERSION.start_with? "3.0"
    entries.delete_if { |dir| dir.include? "/ruby-docs-samples/run/rails" }
  end
  entries
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
