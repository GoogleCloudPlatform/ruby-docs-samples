desc "Updates all Gemfile.lock files under the current directory"

include :fileutils
include :exec, e: true

def run
  Dir.glob "**/Gemfile.lock" do |path|
    dir = File.dirname path
    puts "Updating in #{dir}"
    cd dir do
      rm "Gemfile.lock"
      exec ["bundle", "update"]
    end
  end
end
