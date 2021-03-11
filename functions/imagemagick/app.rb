# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START functions_imagemagick_setup]
require "functions_framework"

FunctionsFramework.on_startup do
  set_global :storage_client do
    require "google/cloud/storage"
    Google::Cloud::Storage.new
  end

  set_global :vision_client do
    require "google/cloud/vision"
    Google::Cloud::Vision.image_annotator
  end
end
# [END functions_imagemagick_setup]

# [START functions_imagemagick_analyze]
# Blurs uploaded images that are flagged as Adult or Violence.
FunctionsFramework.cloud_event "blur_offensive_images" do |event|
  # Event-triggered Ruby functions receive a CloudEvents::Event::V1 object.
  # See https://cloudevents.github.io/sdk-ruby/latest/CloudEvents/Event/V1.html
  # The storage event payload can be obtained from the event data.
  payload = event.data
  file_name = payload["name"]
  bucket_name = payload["bucket"]

  # Ignore already-blurred files
  if file_name.start_with? "blurred-"
    logger.info "The image #{file_name} is already blurred."
    return
  end

  # Get image annotations from the Vision service
  logger.info "Analyzing #{file_name}."
  gs_uri = "gs://#{bucket_name}/#{file_name}"
  result = global(:vision_client).safe_search_detection image: gs_uri
  annotation = result.responses.first.safe_search_annotation

  # Respond to annotations by possibly blurring the image
  if annotation.adult == :VERY_LIKELY || annotation.violence == :VERY_LIKELY
    logger.info "The image #{file_name} was detected as inappropriate."
    blur_image bucket_name, file_name
  else
    logger.info "The image #{file_name} was detected as OK."
  end
end
# [END functions_imagemagick_analyze]

# [START functions_imagemagick_blur]
require "tempfile"
require "mini_magick"

# Blurs the given file using ImageMagick.
def blur_image bucket_name, file_name
  tempfile = Tempfile.new
  begin
    # Download the image file
    bucket = global(:storage_client).bucket bucket_name
    file = bucket.file file_name
    file.download tempfile
    tempfile.close

    # Blur the image using ImageMagick
    MiniMagick::Image.new tempfile.path do |image|
      image.blur "0x16"
    end
    logger.info "Image #{file_name} was blurred"

    # Upload result to a second bucket, to avoid re-triggering the function.
    # You could instead re-upload it to the same bucket and tell your function
    # to ignore files marked as blurred (e.g. those with a "blurred" prefix.)
    blur_bucket_name = ENV["BLURRED_BUCKET_NAME"]
    blur_bucket = global(:storage_client).bucket blur_bucket_name
    blur_bucket.create_file tempfile.path, file_name
    logger.info "Blurred image uploaded to gs://#{blur_bucket_name}/#{file_name}"
  ensure
    # Ruby will remove the temp file when garbage collecting the object,
    # but it is good practice to remove it explicitly.
    tempfile.unlink
  end
end
# [END functions_imagemagick_blur]
