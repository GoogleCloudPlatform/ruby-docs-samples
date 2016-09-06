# Copyright 2016 Google, Inc
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

require_relative "../vision_samples"
require "rspec"
require "tempfile"

describe "Vision sample" do

  # Returns full path to sample image included in repository for testing
  def image_path filename
    File.expand_path "../images/#{filename}", __dir__
  end

  # Capture and return STDOUT output by block
  def capture &block
    real_stdout = $stdout
    $stdout = StringIO.new
    block.call
    @captured_output = $stdout.string
  ensure
    $stdout = real_stdout
  end
  attr_reader :captured_output

# cat.jpg
# eiffel_tower.jpg
# face.png

  example "detect labels" do
    capture { detect_labels path_to_image_file: image_path("cat.jpg") }

    expect(captured_output).to start_with "Image labels:"
    expect(captured_output).to include "cat"
    expect(captured_output).to include "mammal"
  end

  example "detect landmark" do
    expect {
      detect_landmark path_to_image_file: image_path("eiffel_tower.jpg")
    }.to output(
      "Found landmark: Eiffel Tower\n"
    ).to_stdout
  end

  example "detect faces" do
    output_image_file = Tempfile.new "cloud-vision-testing"
    expect(File.size output_image_file.path).to eq 0

    begin
      capture do
        detect_faces path_to_image_file: image_path("face.png"),
                     path_to_output_file: output_image_file.path
      end

      expect(captured_output).to include "Face bounds:"
      expect(captured_output).to include "(154, 33)"
      expect(captured_output).to include "(301, 33)"
      expect(captured_output).to include "(301, 180)"
      expect(captured_output).to include "(154, 180)"
      expect(File.size output_image_file.path).to be > 0
    ensure
      output_image_file.close
      output_image_file.unlink
    end
  end
end
