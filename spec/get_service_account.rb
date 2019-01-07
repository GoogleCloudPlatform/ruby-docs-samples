if __FILE__ == $PROGRAM_NAME
  require "json"

  project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  gfile_dir = ENV["KOKORO_GFILE_DIR"]
  files = Dir.entries(gfile_dir).select do |entry| 
    !File.directory?(entry) && entry.split(".").last == "json"
  end

  files.each do |file|
    filename = File.expand_path(File.join(gfile_dir, file))
    content = JSON.parse(File.read(filename))
    if content["project_id"] == project_id
      return STDOUT.write filename
    end
  end
end
