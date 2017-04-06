require_relative "../language_samples"
require "rspec"
require "tempfile"
require "google/cloud/language"
require "google/cloud/storage"

describe "Google Cloud Natural Language API samples" do

  before do
    @project_id  = Google::Cloud::Language.new.project
    @bucket_name = ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]
    @storage     = Google::Cloud::Storage.new
    @bucket      = @storage.bucket @bucket_name
    @uploaded    = []

    @storage.create_bucket @bucket_name unless @storage.bucket @bucket_name
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

  example "document sentiment from text" do
    positive_text = "Happy love it. I am glad, pleased, and delighted."
    negative_text = "I hate it. I am mad, annoyed, and irritated."
    positive_output = /Overall document sentiment: \(\d\.\d+\)$/
    negative_output = /Overall document sentiment: \(-\d\.\d+\)$/

    expect {
      sentiment_from_text project_id: @project_id, text_content: positive_text
    }.to output(positive_output).to_stdout

    expect {
      sentiment_from_text project_id: @project_id, text_content: negative_text
    }.to output(negative_output).to_stdout

  end

  example "sentence-level sentiment from text" do
    positive_text = "Happy love it. I am glad, pleased, and delighted."
    negative_text = "I hate it. I am mad, annoyed, and irritated."
    positive_output = /Sentence .*\n^.*\(\d\.\d+\)$\n^.*\(\d\.\d+\)$/
    negative_output = /Sentence .*\n^.*\(-\d\.\d+\)$\n^.*\(-\d\.\d+\)$/

    expect {
      sentiment_from_text project_id: @project_id, text_content: positive_text
    }.to output(positive_output).to_stdout

    expect {
      sentiment_from_text project_id: @project_id, text_content: negative_text
    }.to output(negative_output).to_stdout

  end

  example "document sentiment from a file in Google Cloud Storage" do
    upload "positive.txt", "Happy love it. I am glad, pleased, and delighted."
    upload "negative.txt", "I hate it. I am mad, annoyed, and irritated."
    positive_output = /Overall document sentiment: \(\d\.\d+\)$/
    negative_output = /Overall document sentiment: \(-\d\.\d+\)$/

    expect {
      sentiment_from_cloud_storage_file(
        project_id:   @project_id,
        storage_path: "gs://#{@bucket_name}/positive.txt"
      )
    }.to output(positive_output).to_stdout

    expect {
      sentiment_from_cloud_storage_file(
        project_id:   @project_id,
        storage_path: "gs://#{@bucket_name}/negative.txt"
      )
    }.to output(negative_output).to_stdout
  end

  example "sentence-level sentiment from a file in Google Cloud Storage" do
    upload "positive.txt", "Happy love it. I am glad, pleased, and delighted."
    upload "negative.txt", "I hate it. I am mad, annoyed, and irritated."
    positive_output = /Sentence .*\n^.*\(\d\.\d+\)$\n^.*\(\d\.\d+\)$/
    negative_output = /Sentence .*\n^.*\(-\d\.\d+\)$\n^.*\(-\d\.\d+\)$/

    expect {
      sentiment_from_cloud_storage_file(
        project_id:   @project_id,
        storage_path: "gs://#{@bucket_name}/positive.txt"
      )
    }.to output(positive_output).to_stdout

    expect {
      sentiment_from_cloud_storage_file(
        project_id:   @project_id,
        storage_path: "gs://#{@bucket_name}/negative.txt"
      )
    }.to output(negative_output).to_stdout
  end

  example "entities from text" do
    output = capture {
      entities_from_text project_id:   @project_id,
                        text_content: "Alice wrote a book. Bob likes the book."
    }

    expect(output).to include "Alice PERSON"
    expect(output).to include "Bob PERSON"
  end

  example "entities with metadata from text" do
    output = capture {
      entities_from_text project_id:   @project_id,
                        text_content: "William Shakespeare is great."
    }

    expect(output).to include "Entity William Shakespeare PERSON"
    expect(output).to include "wikipedia.org/wiki/William_Shakespeare"
  end

  example "entities from a file in Google Cloud Storage" do
    upload "entities.txt", "Alice wrote a book. Bob likes the book."

    output = capture {
      entities_from_cloud_storage_file(
        project_id:   @project_id,
        storage_path: "gs://#{@bucket_name}/entities.txt"
      )
    }

    expect(output).to include "Alice PERSON"
    expect(output).to include "Bob PERSON"
  end

  example "entities with metadata from a file in Google Cloud Storage" do
    upload "entities.txt", "William Shakespeare is great."

    output = capture {
      entities_from_cloud_storage_file(
        project_id:   @project_id,
        storage_path: "gs://#{@bucket_name}/entities.txt"
      )
    }

    expect(output).to include "Entity William Shakespeare PERSON"
    expect(output).to include "wikipedia.org/wiki/William_Shakespeare"
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
