#!/usr/bin/env ruby
# Copyright 2015 Google, Inc.
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

# This script uses the Vision API's label detection capabilities to find a label
# based on an image's content.
#
# To run the example, install the necessary libraries by running:
#
#     bundle install
#
# Run the script on an image to get a label, E.g.:
#
#     ./label.rb <path-to-image>

require "optparse"

module Samples
  module Vision
    class Label
      require "google/cloud"
      # Run a label request on a single image
      def label_image project_id, image_path
        gcloud = Google::Cloud.new project_id
        vision = gcloud.vision

        image = vision.image image_path
        labels = image.labels
        label = labels.first
        puts "Found label #{label.description} for #{image_path}"
      end

      def self.help
        puts "Usage:"
        puts "./label.rb <path-to-image>"
        puts "or"
        puts "./label.rb <path-to-image> <project_id>"
      end
    end

    if __FILE__ == $PROGRAM_NAME
      image = ARGV[0]
      project_id = ARGV[1]
      if !image.nil?
        Label.new.label_image project_id, image
      else
        Label.help
      end
    end
  end
end
