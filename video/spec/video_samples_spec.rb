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
    @labels_file        = "cloud-samples-data/video/cat.mp4"
    @shots_file         = "cloud-samples-data/video/gbikes_dinosaur.mp4"
    @safe_search_file   = "cloud-samples-data/video/pizza.mp4"
    @transcription_file = "cloud-samples-data/video/googlework_short.mp4"
  end

  it "can analyze labels from a gcs file" do
    expect {
      analyze_labels_gcs path: "gs://#{@labels_file}"
    }.to output(
      /Label description: animal/
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
        /Label description: animal/
      ).to_stdout
    ensure
      local_tempfile.close
      local_tempfile.unlink
    end
  end

  it "can analyze explicit content from a gcs file" do
    expect {
      analyze_explicit_content path: "gs://#{@safe_search_file}"
    }.to output(
      /pornography: VERY_UNLIKELY/
    ).to_stdout
  end

  it "can analyze shots from a gcs file" do
    expect {
      analyze_shots path: "gs://#{@shots_file}"
    }.to output(
      /0.0 to 5/
    ).to_stdout
  end

  it "can transcribe speech from a gcs file" do
    expect {
      transcribe_speech_gcs path: "gs://#{@transcription_file}"
    }.to output(
      /cultural/
    ).to_stdout
  end

  it "can detect texts from a gcs file" do
    expect {
      detect_text_gcs path: "gs://#{@transcription_file}"
    }.to output(
      /GOOGLE/
    ).to_stdout
  end

  it "can detect texts from a local file" do
    begin
      local_tempfile = Tempfile.new "temp_video"
      File.open local_tempfile.path, "w" do |file|
        file_contents = Net::HTTP.get URI("http://storage.googleapis.com/#{@transcription_file}")
        file.write file_contents
        file.flush
      end

      expect {
        detect_text_local path: local_tempfile.path
      }.to output(
        /GOOGLE/
      ).to_stdout
    ensure
      local_tempfile.close
      local_tempfile.unlink
    end
  end

  it "can track objects from a gcs file" do
    expect {
      track_objects_gcs path: "gs://#{@labels_file}"
    }.to output(
      /cat/
    ).to_stdout
  end

  it "can track objects from a local file" do
    begin
      local_tempfile = Tempfile.new "temp_video"
      File.open local_tempfile.path, "w" do |file|
        file_contents = Net::HTTP.get URI("http://storage.googleapis.com/#{@labels_file}")
        file.write file_contents
        file.flush
      end

      expect {
        track_objects_local path: local_tempfile.path
      }.to output(
        /cat/
      ).to_stdout
    ensure
      local_tempfile.close
      local_tempfile.unlink
    end
  end
end
