if __FILE__ == $PROGRAM_NAME
  require "json"

  project_id = ARGV.shift
  gfile_dir = ARGV.shift
  files = Dir.entries(gfile_dir).select do |entry|
    !File.directory?(entry) && entry.split(".").last == "json"
  end

  files.each do |file|
    filename = File.expand_path(file)
    content = JSON.parse(File.read(filename))
    if content["project_id"] == project_id
      return STDOUT.write filename
    end
  end
end
