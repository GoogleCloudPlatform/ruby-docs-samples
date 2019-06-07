# Copyright 2019 Google LLC
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

# DO NOT EDIT! This is a generated sample ("Request",  "vision_batch_annotate_files")

# sample-metadata
#   title:
#   description: Perform batch file annotation
#   bundle exec ruby samples/v1/vision_batch_annotate_files.rb [--file_path "resources/kafka.pdf"]

require "google/cloud/vision"

# [START vision_batch_annotate_files]

 # Perform batch file annotation
 #
 # @param file_path {String} Path to local pdf file, e.g. /path/document.pdf
def sample_batch_annotate_files(file_path)
  # [START vision_batch_annotate_files_core]
  # Instantiate a client
  image_annotator_client = Google::Cloud::Vision::ImageAnnotator.new version: :v1

  # file_path = "resources/kafka.pdf"

  # Supported mime_type: application/pdf, image/tiff, image/gif
  mime_type = "application/pdf"
  content = File.binread file_path
  input_config = { mime_type: mime_type, content: content }
  type = :DOCUMENT_TEXT_DETECTION
  features_element = { type: type }
  features = [features_element]

  # The service can process up to 5 pages per document file. Here we specify the first, second, and
  # last page of the document to be processed.
  pages_element = 1
  pages_element_2 = 2
  pages_element_3 = -1
  pages = [pages_element, pages_element_2, pages_element_3]
  requests_element = {
    input_config: input_config,
    features: features,
    pages: pages
  }
  requests = [requests_element]

  response = image_annotator_client.batch_annotate_files(requests)
  response.responses[0].responses.each do |image_response|
    puts "Full text: #{image_response.full_text_annotation.text}"
    image_response.full_text_annotation.pages.each do |page|
      page.blocks.each do |block|
        puts "\nBlock confidence: #{block.confidence}"
        block.paragraphs.each do |par|
          puts "\tParagraph confidence: #{par.confidence}"
          par.words.each do |word|
            puts "\t\tWord confidence: #{word.confidence}"
            word.symbols.each do |symbol|
              puts "\t\t\tSymbol: #{symbol.text}, (confidence: #{symbol.confidence})"
            end
          end
        end
      end
    end
  end

  # [END vision_batch_annotate_files_core]
end
# [END vision_batch_annotate_files]


require "optparse"

if $0 == __FILE__

  file_path = "resources/kafka.pdf"

  ARGV.options do |opts|
    opts.on("--file_path=val") { |val| file_path = val }
    opts.parse!
  end


  sample_batch_annotate_files(file_path)
end