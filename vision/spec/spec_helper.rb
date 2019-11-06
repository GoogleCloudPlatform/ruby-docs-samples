require "google/cloud/vision"

def version
  versions = Google::Cloud::Vision::AVAILABLE_VERSIONS
  versions = versions.reject { |v| v.include? "beta" }
  versions.max_by { |v| v.match(/\d+/)[0].to_i }
end
