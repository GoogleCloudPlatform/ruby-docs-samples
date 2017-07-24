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

# [START videointelligence_quickstart]
require "google/cloud/video_intelligence/v1beta1"

video_client = Google::Cloud::VideoIntelligence::V1beta1::VideoIntelligenceServiceClient.new
features     = [:LABEL_DETECTION]
path         = "gs://demomaker/cat.mp4"

# Register a callback during the method call
operation = video_client.annotate_video path, features do |operation|
  raise operation.results.message? if operation.error?
  puts "Finished Processing."

  # first result is retrieved because a single video was processed
  annotation_result = operation.results.annotation_results.first

  annotation_result.label_annotations.each do |label_annotation|
    puts "Label description: #{label_annotation.description}"
    puts "Locations:"

    label_annotation.locations.each do |location|
      if location.level == :VIDEO_LEVEL
        puts "Entire video"
      else
        segment          = location.segment
        start_in_seconds = segment.start_time_offset / 1000000.0
        end_in_seconds   = segment.end_time_offset / 1000000.0

        puts "#{start_in_seconds} through #{end_in_seconds}"
      end
    end
  end
end

puts "Processing video for label annotations:"
operation.wait_until_done!
# [END videointelligence_quickstart]

