# Copyright 2017 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../video_samples"
require "rspec"
require "tempfile"
require "net/http"
require "uri"

describe "Google Cloud Video API sample" do

  before do
    @faces_file       = "demomaker/google_gmail.mp4"
    @labels_file      = "demomaker/cat.mp4"
    @shots_file       = "demomaker/gbikes_dinosaur.mp4"
    @safe_search_file = "demomaker/google_gmail.mp4"
  end

  it "can analyze labels from a gcs file" do
   expect {
     analyze_labels_gcs path: "gs://#{@labels_file}"
   }.to output(
     /Label description: Animal/
   ).to_stdout
  end

  it "can analyze labels from a local file" do
    begin
      local_tempfile = Tempfile.new "temp_video"
      File.open local_tempfile.path, "w" do |file|
        file_contents = Net::HTTP.get URI("http://storage.googleapis.com/#{@labels_file}")
        file.write file_contents
        file.flush
      end

      expect {
        analyze_labels_local path: local_tempfile.path
      }.to output(
        /Label description: Animal/
      ).to_stdout
    ensure
      local_tempfile.close
      local_tempfile.unlink
    end
  end

  it "can analyze faces from a gcs file" do
    expect {
      analyze_faces path: "gs://#{@labels_file}"
    }.to output(
      /Thumbnail size: \d+/
    ).to_stdout
  end

  it "can analyze safe search from a gcs file" do
    expect {
      analyze_safe_search path: "gs://#{@safe_search_file}"
    }.to output(
      /adult:   VERY_UNLIKELY/
    ).to_stdout
  end

  it "can analyze shots from a gcs file" do
    expect {
      analyze_shots path: "gs://#{@shots_file}"
    }.to output(
      /Scene 2: \d+.\d+s to \d/
    ).to_stdout
  end
end

