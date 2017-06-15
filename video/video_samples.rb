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

def analyze_labels_gcs path:
  # [START analyze_labels_gcs]
  # path = "Path to a video file on Google Cloud Storage: gs://bucket/video.mp4"

  require "google/cloud/video_intelligence/v1beta1"

  video_client = Google::Cloud::VideoIntelligence::V1beta1::VideoIntelligenceServiceClient.new
  features     = [Google::Cloud::Videointelligence::V1beta1::Feature::LABEL_DETECTION]

  # Register a callback during the method call
  operation = video_client.annotate_video path, features do |operation|
    raise operation.results.message? if operation.error?
    puts "Video labels completed"

    annotation_results = operation.results.annotation_results

    if annotation_results.any?
      annotation_results.each do |annotation_result|
        puts "Labels:"
        annotation_result.label_annotations.each do |label_annotation|
          puts "\tDescription: #{label_annotation.description}"
          label_annotation.locations.each do |location|
            if location.level == :VIDEO_LEVEL
              puts "\tLocation: Entire video"
            else
              segment      = location.segment
              start_offset = segment.start_time_offset / 1000000.0
              end_offset   = segment.end_time_offset / 1000000.0
              puts "\tLocation: #{start_offset}s - #{end_offset}s"
            end
          end
        end
      end
    else
      puts "No labels detected in #{path}"
    end
  end

  puts "Waiting for operation to complete..."
  operation.wait_until_done!
  # [END analyze_labels_gcs]
end

def analyze_labels_local path:
  # [START analyze_labels_local]
  # path = "Path to a local video file: path/to/file.mp4"

  require "base64"
  require "google/cloud/video_intelligence/v1beta1"

  video_client = Google::Cloud::VideoIntelligence::V1beta1::VideoIntelligenceServiceClient.new
  features     = [Google::Cloud::Videointelligence::V1beta1::Feature::LABEL_DETECTION]

  video_contents         = File.read path
  encoded_video_contents = Base64.encode64 video_contents

  # Register a callback during the method call
  operation = video_client.annotate_video nil, features, input_content: encoded_video_contents do |operation|
    raise operation.results.message? if operation.error?
    puts "Video labels completed"

    annotation_results = operation.results.annotation_results

    if annotation_results.any?
      annotation_results.each do |annotation_result|
        puts "Labels:"
        annotation_result.label_annotations.each do |label_annotation|
          puts "\tDescription: #{label_annotation.description}"
          label_annotation.locations.each do |location|
            if location.level == :VIDEO_LEVEL
              puts "\tLocation: Entire video"
            else
              segment      = location.segment
              start_offset = segment.start_time_offset / 1000000.0
              end_offset   = segment.end_time_offset / 1000000.0
              puts "\tLocation: #{start_offset}s - #{end_offset}s"
            end
          end
        end
      end
    else
      puts "No labels detected in #{path}"
    end
  end

  puts "Waiting for operation to complete..."
  operation.wait_until_done!
  # [END analyze_labels_local]
end

def analyze_faces path:
  # [START analyze_faces]
  # path = "Path to a video file on Google Cloud Storage: gs://bucket/video.mp4"

  require "google/cloud/video_intelligence/v1beta1"

  video_client = Google::Cloud::VideoIntelligence::V1beta1::VideoIntelligenceServiceClient.new
  features     = [Google::Cloud::Videointelligence::V1beta1::Feature::FACE_DETECTION]

  # Register a callback during the method call
  operation = video_client.annotate_video path, features do |operation|
    raise operation.results.message? if operation.error?
    annotation_results = operation.results.annotation_results

    annotation_results.each do |annotation_result|
      if annotation_result.face_annotations.any?
        annotation_result.face_annotations.each do |face_annotation|
          puts "Thumbnail size: #{face_annotation.thumbnail.length}"
          face_annotation.segments.each do |segment|
            start_offset = segment.start_time_offset / 1000000.0
            end_offset   = segment.end_time_offset / 1000000.0

            puts "\tLocation: #{start_offset}s - #{end_offset}s"
          end
        end
      else
        puts "No faces detected in #{path}"
      end
    end
  end

  puts "Processing video for face annotations:"
  operation.wait_until_done!
  puts "Finished processing"
  # [END analyze_faces]
end

def analyze_safe_search path:
  # [START analyze_safe_search]
  # path = "Path to a video file on Google Cloud Storage: gs://bucket/video.mp4"

  require "google/cloud/video_intelligence/v1beta1"

  video_client = Google::Cloud::VideoIntelligence::V1beta1::VideoIntelligenceServiceClient.new
  features     = [Google::Cloud::Videointelligence::V1beta1::Feature::SAFE_SEARCH_DETECTION]

  # Register a callback during the method call
  operation = video_client.annotate_video path, features do |operation|
    raise operation.results.message? if operation.error?
    annotation_results = operation.results.annotation_results

    annotation_results.each do |annotation_result|
      annotation_result.safe_search_annotations.each do |safe_search_annotation|
        puts "Time: #{safe_search_annotation.time_offset / 1000000.0}"
        puts "\tadult:   #{safe_search_annotation.adult}"
        puts "\tspoof:   #{safe_search_annotation.spoof}"
        puts "\tmedical: #{safe_search_annotation.medical}"
        puts "\tracy:    #{safe_search_annotation.racy}"
        puts "\tviolent: #{safe_search_annotation.violent}"
      end
    end
  end

  puts "Processing video for face annotations:"
  operation.wait_until_done!
  puts "Finished processing"
  # [END analyze_safe_search]
end

def analyze_shots path:
  # [START analyze_shots]
  # path = "Path to a video file on Google Cloud Storage: gs://bucket/video.mp4"

  require "google/cloud/video_intelligence/v1beta1"

  video_client = Google::Cloud::VideoIntelligence::V1beta1::VideoIntelligenceServiceClient.new
  features     = [Google::Cloud::Videointelligence::V1beta1::Feature::SHOT_CHANGE_DETECTION]

  # Register a callback during the method call
  operation = video_client.annotate_video path, features do |operation|
    raise operation.results.message? if operation.error?
    annotation_results = operation.results.annotation_results

    shot_number = 1

    annotation_results.each do |annotation_result|
      annotation_result.shot_annotations.each do |shot_annotation|
        start_time = shot_annotation.start_time_offset / 1000000.0
        end_time   = shot_annotation.end_time_offset / 1000000.0

        puts "\t Scene #{shot_number}: #{start_time}s to #{end_time}"
        shot_number += 1
      end
    end
  end

  puts "Processing video for shot change annotations:"
  operation.wait_until_done!
  puts "Finished processing"
  # [END analyze_shots]
end

def run_sample arguments
  command = arguments.shift

  case command
  when "analyze_labels"
    analyze_labels_gcs path: arguments.shift
  when "analyze_labels_local"
    analyze_labels_local path: arguments.shift
  when "analyze_faces"
    analyze_faces path: arguments.shift
  when "analyze_safe_search"
    analyze_safe_search path: arguments.shift
  when "analyze_shots"
    analyze_shots path: arguments.shift
  else
    puts <<-usage
Usage: bundle exec ruby video_samples.rb [command] [arguments]

Commands:
  analyze_labels       <gcs_path> Detects labels given a GCS path.
  analyze_labels_local <local_path> Detects labels given file path.
  analyze_faces        <gcs_path> Analyze Detects faces given a GCS path.
  analyze_safe_search  <gcs_path>
  analyze_shots        <gcs_path>
    usage
  end
end

if $PROGRAM_NAME == __FILE__
  run_sample ARGV
end

