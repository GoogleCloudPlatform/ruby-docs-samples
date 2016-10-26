require_relative "../language_samples"
require "rspec"
require "tempfile"
require "google/cloud"

describe "Google Cloud Natural Language API samples" do

  before do
    @project_id  = ENV["GOOGLE_CLOUD_PROJECT"]
    @bucket_name = ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]
    @gcloud      = Google::Cloud.new @project_id
    @storage     = @gcloud.storage
    @bucket      = @storage.bucket @bucket_name
    @uploaded    = []
  end

  after do
    @uploaded.each do |file_name|
      file = @bucket.file file_name
      file.delete if file
    end
  end

  # Upload a file to Google Cloud Storage for testing
  # Uploaded files will be deleted after each test
  def upload file_name, text_content
    local_file = Tempfile.new "language-test-file"
    File.write local_file.path, text_content
    @bucket.create_file local_file.path, file_name
    @uploaded << file_name
  ensure
    local_file.close
    local_file.unlink
  end

  # Capture and return STDOUT output by block
  def capture &block
    real_stdout = $stdout
    $stdout = StringIO.new
    block.call
    $stdout.string
  ensure
    $stdout = real_stdout
  end

  example "sentiment from text" do
    positive_text = "Matz is nice so we are nice"
    negative_text = "I am angry. I hate things."

    expect {
      sentiment_from_text project_id: @project_id, text_content: positive_text
    }.to output(/^1.0 /).to_stdout

    expect {
      sentiment_from_text project_id: @project_id, text_content: negative_text
    }.to output(/^-1.0 /).to_stdout
  end

  example "sentiment from a file stored in Google Cloud Storage" do
    upload "positive_text.txt", "Matz is nice so we are nice"
    upload "negative_text.txt", "I am angry. I hate things."

    expect {
      sentiment_from_cloud_storage_file(
        project_id:   @project_id,
        storage_path: "gs://#{@bucket_name}/positive_text.txt"
      )
    }.to output(/^1.0 /).to_stdout

    expect {
      sentiment_from_cloud_storage_file(
        project_id:   @project_id,
        storage_path: "gs://#{@bucket_name}/negative_text.txt"
      )
    }.to output(/^-1.0 /).to_stdout
  end

  example "entries from text" do
    output = capture {
      entries_from_text project_id:   @project_id,
                        text_content: "Alice wrote a book. Bob likes the book."
    }

    expect(output).to include "Alice PERSON"
    expect(output).to include "Bob PERSON"
  end

  example "entries from a file stored in Google Cloud Storage" do
    upload "entries.txt", "Alice wrote a book. Bob likes the book."

    output = capture {
      entries_from_cloud_storage_file(
        project_id:   @project_id,
        storage_path: "gs://#{@bucket_name}/entries.txt"
      )
    }

    expect(output).to include "Alice PERSON"
    expect(output).to include "Bob PERSON"
  end

  example "syntax from text" do
    output = capture {
      syntax_from_text(
        project_id: @project_id,
        text_content: "I am Fox Tall. The porcupine stole my pickup truck."
      )
    }

    expect(output).to include "Sentences: 2"
    expect(output).to include "Tokens: 12"
    expect(output).to include "PRON I"
    expect(output).to include "VERB am"
    expect(output).to include "NOUN Fox"
  end

  example "syntax from a file stored in Google Cloud Storage" do
    upload "syntax.txt", "I am Fox Tall. The porcupine stole my pickup truck."

    output = capture {
      syntax_from_cloud_storage_file(
        project_id:   @project_id,
        storage_path: "gs://#{@bucket_name}/syntax.txt"
      )
    }

    expect(output).to include "Sentences: 2"
    expect(output).to include "Tokens: 12"
    expect(output).to include "PRON I"
    expect(output).to include "VERB am"
    expect(output).to include "NOUN Fox"
  end
end
