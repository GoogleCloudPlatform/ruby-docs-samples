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
    puts "Finished Processing."

    # first result is retrieved because a single video was processed
    annotation_result = operation.results.annotation_results.first

    annotation_result.label_annotations.each do |label_annotation|
      puts "Label description: #{label_annotation.description}"
      puts "Locations:"

      label_annotation.locations.each do |location|
        positions = "Entire video"

        if location.level != :VIDEO_LEVEL
          segment      = location.segment
          start_offset = segment.start_time_offset / 1000000.0
          end_offset   = segment.end_time_offset / 1000000.0

          positions = "#{start_offset}s - #{end_offset}s"
        end

        puts "\t#{positions}"
      end
    end
  end

  puts "Processing video for label annotations:"
  operation.wait_until_done!
  # [END analyze_labels_gcs]
end

def analyze_labels_local path:
  # [START analyze_labels_local]
  # path = "Path to a local video file: path/to/file.mp4"

  require "base64"
  require "google/cloud/video_intelligence/v1beta1"

  video_client  = Google::Cloud::VideoIntelligence::V1beta1::VideoIntelligenceServiceClient.new
  features      = [Google::Cloud::Videointelligence::V1beta1::Feature::LABEL_DETECTION]
  video_file    = File.read path
  encoded_video = Base64.encode64 video_file

  # Register a callback during the method call
  operation = video_client.annotate_video nil, features, input_content: encoded_video do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished processing."

    # first result is retrieved because a single video was processed
    annotation_result = operation.results.annotation_results.first

    annotation_result.label_annotations.each do |label_annotation|
      puts "Label description: #{label_annotation.description}"
      puts "Locations:"

      label_annotation.locations.each do |location|
        positions = "Entire video"

        if location.level != :VIDEO_LEVEL
          segment      = location.segment
          start_offset = segment.start_time_offset / 1000000.0
          end_offset   = segment.end_time_offset / 1000000.0

          positions = "#{start_offset}s - #{end_offset}s"
        end

        puts "\t#{positions}"
      end
    end
  end

  puts "Processing video for label annotations:"
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
    puts "Finished processing."

    # first result is retrieved because a single video was processed
    annotation_result = operation.results.annotation_results.first

    annotation_result.face_annotations.each do |face_annotation|
      segment_id = 1
      puts "Thumbnail size: #{face_annotation.thumbnail.length}"

      face_annotation.segments.each do |segment|
        positions = 'Entire video'

        if segment.start_time_offset != -1 && segment.end_time_offset != -1
          start_offset = segment.start_time_offset / 1000000.0
          end_offset   = segment.end_time_offset / 1000000.0
          positions    = "#{start_offset}s - #{end_offset}s"
        end

        puts "\tLocation #{segment_id}: #{positions}"
        segment_id += 1
      end
    end
  end

  puts "Processing video for face annotations:"
  operation.wait_until_done!
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
    puts "Finished processing."

    # first result is retrieved because a single video was processed
    annotation_result = operation.results.annotation_results.first

    annotation_result.safe_search_annotations.each do |safe_search_annotation|
      puts "Time: #{safe_search_annotation.time_offset / 1000000.0}"
      puts "\tadult:   #{safe_search_annotation.adult}"
      puts "\tspoof:   #{safe_search_annotation.spoof}"
      puts "\tmedical: #{safe_search_annotation.medical}"
      puts "\tracy:    #{safe_search_annotation.racy}"
      puts "\tviolent: #{safe_search_annotation.violent}"
    end
  end

  puts "Processing video for face annotations:"
  operation.wait_until_done!
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
    puts "Finished processing."

    # first result is retrieved because a single video was processed
    annotation_result = operation.results.annotation_results.first
    shot_number       = 1

    annotation_result.shot_annotations.each do |shot_annotation|
      start_time = shot_annotation.start_time_offset / 1000000.0
      end_time   = shot_annotation.end_time_offset / 1000000.0

      puts "Scene #{shot_number}: #{start_time}s to #{end_time}"
      shot_number += 1
    end
  end

  puts "Processing video for shot change annotations:"
  operation.wait_until_done!
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
  analyze_labels       <gcs_path>   Detects labels given a GCS path.
  analyze_labels_local <local_path> Detects labels given file path.
  analyze_faces        <gcs_path>   Detects faces given a GCS path.
  analyze_safe_search  <gcs_path>   Detects safe search features the GCS path to a video.
  analyze_shots        <gcs_path>   Detects camera shot changes.
    usage
  end
end

if $PROGRAM_NAME == __FILE__
  run_sample ARGV
end

