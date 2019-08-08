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
        start_time = (segment.segment.start_time_offset.seconds +
                       segment.segment.start_time_offset.nanos / 1e9)
        end_time =   (segment.segment.end_time_offset.seconds +
                       segment.segment.end_time_offset.nanos / 1e9)

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
  # [START video_analyze_labels]
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
        start_time = (segment.segment.start_time_offset.seconds +
                       segment.segment.start_time_offset.nanos / 1e9)
        end_time =   (segment.segment.end_time_offset.seconds +
                       segment.segment.end_time_offset.nanos / 1e9)

        puts "Segment: #{start_time} to #{end_time}"
        puts "Confidence: #{segment.confidence}"
      end
    end
  end

  puts "Processing video for label annotations:"
  operation.wait_until_done!
  # [END video_analyze_labels]
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
      start_time = (shot_annotation.start_time_offset.seconds +
                     shot_annotation.start_time_offset.nanos / 1e9)
      end_time =   (shot_annotation.end_time_offset.seconds +
                     shot_annotation.end_time_offset.nanos / 1e9)

      puts "#{start_time} to #{end_time}"
    end
  end

  puts "Processing video for shot change annotations:"
  operation.wait_until_done!
  # [END video_analyze_shots]
end

def analyze_explicit_content path:
  # [START video_analyze_explicit_content]
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
  # [END video_analyze_explicit_content]
end

def transcribe_speech_gcs path:
  # [START video_speech_transcription_gcs]
  # path = "Path to a video file on Google Cloud Storage: gs://bucket/video.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  context = {
    speech_transcription_config: {
      language_code:                "en-US",
      enable_automatic_punctuation: true
    }
  }

  # Register a callback during the method call
  operation = video.annotate_video input_uri: path, features: [:SPEECH_TRANSCRIPTION], video_context: context do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished Processing."

    transcriptions = operation.results.annotation_results.first.speech_transcriptions

    transcriptions.each do |transcription|
      transcription.alternatives.each do |alternative|
        puts "Alternative level information:"

        puts "Transcript: #{alternative.transcript}"
        puts "Confidence: #{alternative.confidence}"

        puts "Word level information:"
        alternative.words.each do |word_info|
          start_time = (word_info.start_time.seconds +
                         word_info.start_time.nanos / 1e9)
          end_time =   (word_info.end_time.seconds +
                         word_info.end_time.nanos / 1e9)

          puts "#{word_info.word}: #{start_time} to #{end_time}"
        end
      end
    end
  end

  puts "Processing video for speech transcriptions:"
  operation.wait_until_done!
  # [END video_speech_transcription_gcs]
end

def detect_text_gcs path:
  # [START video_detect_text_gcs]
  # path = "Path to a video file on Google Cloud Storage: gs://bucket/video.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  # Register a callback during the method call
  operation = video.annotate_video input_uri: path, features: [:TEXT_DETECTION] do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished Processing."

    text_annotations = operation.results.annotation_results.first.text_annotations

    text_annotations.each do |text_annotation|
      puts "Text: #{text_annotation.text}"

      # Print information about the first segment of the text.
      text_segment = text_annotation.segments.first
      start_time_offset = text_segment.segment.start_time_offset
      end_time_offset = text_segment.segment.end_time_offset
      start_time = (start_time_offset.seconds +
                     start_time_offset.nanos / 1e9)
      end_time =   (end_time_offset.seconds +
                     end_time_offset.nanos / 1e9)
      puts "start_time: #{start_time}, end_time: #{end_time}"

      puts "Confidence: #{text_segment.confidence}"

      # Print information about the first frame of the segment.
      frame = text_segment.frames.first
      time_offset = (frame.time_offset.seconds +
                      frame.time_offset.nanos / 1e9)
      puts "Time offset for the first frame: #{time_offset}"

      puts "Rotated bounding box vertices:"
      frame.rotated_bounding_box.vertices.each do |vertex|
        puts "\tVertex.x: #{vertex.x}, Vertex.y: #{vertex.y}"
      end
    end
  end

  puts "Processing video for text detection:"
  operation.wait_until_done!
  # [END video_detect_text_gcs]
end

def detect_text_local path:
  # [START video_detect_text]
  # "Path to a local video file: path/to/file.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  video_contents = File.binread path

  # Register a callback during the method call
  operation = video.annotate_video input_content: video_contents, features: [:TEXT_DETECTION] do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished Processing."

    text_annotations = operation.results.annotation_results.first.text_annotations

    text_annotations.each do |text_annotation|
      puts "Text: #{text_annotation.text}"

      # Print information about the first segment of the text.
      text_segment = text_annotation.segments.first
      start_time_offset = text_segment.segment.start_time_offset
      end_time_offset = text_segment.segment.end_time_offset
      start_time = (start_time_offset.seconds +
                     start_time_offset.nanos / 1e9)
      end_time =   (end_time_offset.seconds +
                     end_time_offset.nanos / 1e9)
      puts "start_time: #{start_time}, end_time: #{end_time}"

      puts "Confidence: #{text_segment.confidence}"

      # Print information about the first frame of the segment.
      frame = text_segment.frames.first
      time_offset = (frame.time_offset.seconds +
                      frame.time_offset.nanos / 1e9)
      puts "Time offset for the first frame: #{time_offset}"

      puts "Rotated bounding box vertices:"
      frame.rotated_bounding_box.vertices.each do |vertex|
        puts "\tVertex.x: #{vertex.x}, Vertex.y: #{vertex.y}"
      end
    end
  end

  puts "Processing video for text detection:"
  operation.wait_until_done!
  # [END video_detect_text]
end

def track_objects_gcs path:
  # [START video_object_tracking_gcs]
  # path = "Path to a video file on Google Cloud Storage: gs://bucket/video.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  # Register a callback during the method call
  operation = video.annotate_video input_uri: path, features: [:OBJECT_TRACKING] do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished Processing."

    object_annotations = operation.results.annotation_results.first.object_annotations

    object_annotations.each do |object_annotation|
      puts "Entity description: #{object_annotation.entity.description}"
      puts "Entity id: #{object_annotation.entity.entity_id}" if object_annotation.entity.entity_id

      object_segment = object_annotation.segment
      start_time = (object_segment.start_time_offset.seconds +
                     object_segment.start_time_offset.nanos / 1e9)
      end_time =   (object_segment.end_time_offset.seconds +
                     object_segment.end_time_offset.nanos / 1e9)
      puts "Segment: #{start_time}s to #{end_time}s"

      puts "Confidence: #{object_annotation.confidence}"

      # Print information about the first frame of the segment.
      frame = object_annotation.frames.first
      box = frame.normalized_bounding_box

      time_offset = (frame.time_offset.seconds +
                      frame.time_offset.nanos / 1e9)
      puts "Time offset for the first frame: #{time_offset}s"

      puts "Bounding box position:"
      puts "\tleft  : #{box.left}"
      puts "\ttop   : #{box.top}"
      puts "\tright : #{box.right}"
      puts "\tbottom: #{box.bottom}\n"
    end
  end

  puts "Processing video for object tracking:"
  operation.wait_until_done!
  # [END video_object_tracking_gcs]
end

def track_objects_local path:
  # [START video_object_tracking]
  # "Path to a local video file: path/to/file.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  video_contents = File.binread path

  # Register a callback during the method call
  operation = video.annotate_video input_content: video_contents, features: [:OBJECT_TRACKING] do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished Processing."

    object_annotations = operation.results.annotation_results.first.object_annotations

    object_annotations.each do |object_annotation|
      puts "Entity description: #{object_annotation.entity.description}"
      puts "Entity id: #{object_annotation.entity.entity_id}" if object_annotation.entity.entity_id

      object_segment = object_annotation.segment
      start_time = (object_segment.start_time_offset.seconds +
                     object_segment.start_time_offset.nanos / 1e9)
      end_time =   (object_segment.end_time_offset.seconds +
                     object_segment.end_time_offset.nanos / 1e9)
      puts "Segment: #{start_time}s to #{end_time}s"

      puts "Confidence: #{object_annotation.confidence}"

      # Print information about the first frame of the segment.
      frame = object_annotation.frames.first
      box = frame.normalized_bounding_box

      time_offset = (frame.time_offset.seconds +
                      frame.time_offset.nanos / 1e9)
      puts "Time offset for the first frame: #{time_offset}s"

      puts "Bounding box position:"
      puts "\tleft  : #{box.left}"
      puts "\ttop   : #{box.top}"
      puts "\tright : #{box.right}"
      puts "\tbottom: #{box.bottom}\n"
    end
  end

  puts "Processing video for object tracking:"
  operation.wait_until_done!
  # [END video_object_tracking]
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
  when "transcribe_speech"
    transcribe_speech_gcs path: arguments.shift
  when "detect_text_gcs"
    detect_text_gcs path: arguments.shift
  when "detect_text_local"
    detect_text_local path: arguments.shift
  when "track_objects_gcs"
    track_objects_gcs path: arguments.shift
  when "track_objects_local"
    track_objects_local path: arguments.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby video_samples.rb [command] [arguments]

      Commands:
        analyze_labels           <gcs_path>   Detects labels given a GCS path.
        analyze_labels_local     <local_path> Detects labels given file path.
        analyze_shots            <gcs_path>   Detects camera shot changes given a GCS path.
        analyze_explicit_content <gcs_path>   Detects explicit content given a GCS path.
        transcribe_speech        <gcs_path>   Transcribes speech given a GCS path.
        detect_text_gcs          <gcs_path>   Detects text given a GCS path.
        detect_text_local        <local_path> Detects text given file path.
        track_objects_gcs        <gcs_path>   Track objects given a GCS path.
        track_objects_local      <local_path> Track objects given file path.
    USAGE
  end
end

if $PROGRAM_NAME == __FILE__
  run_sample ARGV
end
