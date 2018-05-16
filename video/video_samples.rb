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
  # [START video_analyze_labels_gcs]
  # path = "Path to a video file on Google Cloud Storage: gs://bucket/video.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  # Register a callback during the method call
  operation = video.annotate_video input_uri: path, features: [:LABEL_DETECTION] do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished Processing."

    labels = operation.results.annotation_results.first.segment_label_annotations

    labels.each do |label|
      puts "Label description: #{label.entity.description}"

      label.category_entities.each do |category_entity|
        puts "Label category description: #{category_entity.description}"
      end

      label.segments.each do |segment|
        start_time = ( segment.segment.start_time_offset.seconds +
                       segment.segment.start_time_offset.nanos / 1e9 )
        end_time =   ( segment.segment.end_time_offset.seconds +
                       segment.segment.end_time_offset.nanos / 1e9 )

        puts "Segment: #{start_time} to #{end_time}"
        puts "Confidence: #{segment.confidence}"
      end
    end
  end

  puts "Processing video for label annotations:"
  operation.wait_until_done!
  # [END video_analyze_labels_gcs]
end

def analyze_labels_local path:
  # [START video_analyze_labels_local]
  # path = "Path to a local video file: path/to/file.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  video_contents = File.binread path

  # Register a callback during the method call
  operation = video.annotate_video input_content: video_contents, features: [:LABEL_DETECTION] do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished Processing."

    labels = operation.results.annotation_results.first.segment_label_annotations

    labels.each do |label|
      puts "Label description: #{label.entity.description}"

      label.category_entities.each do |category_entity|
        puts "Label category description: #{category_entity.description}"
      end

      label.segments.each do |segment|
        start_time = ( segment.segment.start_time_offset.seconds +
                       segment.segment.start_time_offset.nanos / 1e9 )
        end_time =   ( segment.segment.end_time_offset.seconds +
                       segment.segment.end_time_offset.nanos / 1e9 )

        puts "Segment: #{start_time} to #{end_time}"
        puts "Confidence: #{segment.confidence}"
      end
    end
  end

  puts "Processing video for label annotations:"
  operation.wait_until_done!
  # [END video_analyze_labels_local]
end

def analyze_shots path:
  # [START video_analyze_shots]
  # path = "Path to a video file on Google Cloud Storage: gs://bucket/video.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  # Register a callback during the method call
  operation = video.annotate_video input_uri: path, features: [:SHOT_CHANGE_DETECTION] do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished processing."

    # first result is retrieved because a single video was processed
    annotation_result = operation.results.annotation_results.first
    puts "Scenes:"

    annotation_result.shot_annotations.each do |shot_annotation|
      start_time = ( shot_annotation.start_time_offset.seconds +
                     shot_annotation.start_time_offset.nanos / 1e9 )
      end_time =   ( shot_annotation.end_time_offset.seconds +
                     shot_annotation.end_time_offset.nanos / 1e9 )

      puts "#{start_time} to #{end_time}"
    end
  end

  puts "Processing video for shot change annotations:"
  operation.wait_until_done!
  # [END video_analyze_shots]
end

def analyze_explicit_content path:
  # [START video_analyze_explicit_content_gcs]
  # path = "Path to a video file on Google Cloud Storage: gs://bucket/video.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  # Register a callback during the method call
  operation = video.annotate_video input_uri: path, features: [:EXPLICIT_CONTENT_DETECTION] do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished Processing."

    explicit_annotation = operation.results.annotation_results.first.explicit_annotation

    explicit_annotation.frames.each do |frame|
      frame_time = frame.time_offset.seconds + frame.time_offset.nanos / 1e9

      puts "Time: #{frame_time}"
      puts "pornography: #{frame.pornography_likelihood}"
    end
  end

  puts "Processing video for label annotations:"
  operation.wait_until_done!
  # [END video_analyze_explicit_content_gcs]
end

def run_sample arguments
  command = arguments.shift

  case command
  when "analyze_labels"
    analyze_labels_gcs path: arguments.shift
  when "analyze_labels_local"
    analyze_labels_local path: arguments.shift
  when "analyze_shots"
    analyze_shots path: arguments.shift
  when "analyze_explicit_content"
    analyze_explicit_content path: arguments.shift
  else
    puts <<-usage
Usage: bundle exec ruby video_samples.rb [command] [arguments]

Commands:
  analyze_labels           <gcs_path>   Detects labels given a GCS path.
  analyze_labels_local     <local_path> Detects labels given file path.
  analyze_shots            <gcs_path>   Detects camera shot changes given a GCS path.
  analyze_explicit_content <gcs_path>   Detects explicit content given a GCS path.
    usage
  end
end

if $PROGRAM_NAME == __FILE__
  run_sample ARGV
end

