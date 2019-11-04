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

require "rspec"

require_relative "spec_helper"
require_relative "../detect_crop_hints"

require "google/cloud/vision/#{version}"

class AnnotatorMock < Google::Cloud::Vision.const_get(version.capitalize)::ImageAnnotatorClient
  def initialize *args
    super

    @batch_annotate_images = proc do |*_args|
      Google::Cloud::Vision.const_get(version.capitalize)::BatchAnnotateImagesResponse.new(
        responses: [
          Google::Cloud::Vision.const_get(version.capitalize)::AnnotateImageResponse.new(
            crop_hints_annotation: Google::Cloud::Vision.const_get(version.capitalize)::CropHintsAnnotation.new(
              crop_hints: [
                Google::Cloud::Vision.const_get(version.capitalize)::CropHint.new(
                  bounding_poly: Google::Cloud::Vision.const_get(version.capitalize)::BoundingPoly.new(
                    vertices: [Google::Cloud::Vision.const_get(version.capitalize)::Vertex.new(x: 1234, y: 1234)]
                  )
                )
              ]
            )
          )
        ]
      )
    end
  end
end

describe "Detect Crop Hints" do

  # Returns full path to sample image included in repository for testing
  def image_path filename
    File.expand_path "../resources/#{filename}", __dir__
  end

  example "detect crop hints from local image file" do
    allow(Google::Cloud::Vision.const_get(version.capitalize)::ImageAnnotatorClient).to receive(:new).and_return(AnnotatorMock.new)
    expect do
      detect_crop_hints image_path: image_path("otter_crossing.jpg")
    end.to output(
      /1234, 1234/
    ).to_stdout
  end

  example "detect crop hints from image file in Google Cloud Storage" do
    allow(Google::Cloud::Vision.const_get(version.capitalize)::ImageAnnotatorClient).to receive(:new).and_return(AnnotatorMock.new)
    expect do
      detect_crop_hints_gcs image_path: "gs://my-bucket/image.png"
    end.to output(
      /1234, 1234/
    ).to_stdout
  end
end
