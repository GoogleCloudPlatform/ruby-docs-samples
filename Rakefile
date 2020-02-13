require "rake/testtask"

task :test do
  each_lib do |dir|
    test_task dir, "test"
  end
end

task :acceptance do
  each_lib do |dir|
    test_task dir, "test"
    test_task dir, "acceptance"
  end
end

def each_lib
  failed = false
  full_start_time = Time.now
  dirs.each do |dir|
    Dir.chdir dir do
      Bundler.with_clean_env do
        start_time = Time.now
        lib = dir.split("ruby-docs-samples/").last
        begin
          header "Running tests for #{lib}"
          sh "bundle install"
          yield dir
        rescue
          failed = true
        end
        end_time = Time.now
        header_2 "Tests for #{lib} took #{(end_time - start_time).to_i} seconds"
      end
    end
  end
  full_end_time = Time.now
  header_2 "Tests took a total of #{(full_end_time - full_start_time).to_i} seconds"
  raise "Tests failed" if failed
  header "Tests passed"
end

def test_task dir, type
  Rake::TestTask.new "#{dir}_#{type}" do |t|
    t.test_files = FileList["#{dir}/#{type}/**/*_test.rb"]
    t.warning = false
  end
  Rake::Task["#{dir}_#{type}"].invoke
end

def dirs
  entries = Dir.glob("#{__dir__}/**/*_test.rb").map do |entry|
    File.expand_path "..", File.dirname(entry)
  end
  entries.uniq
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
