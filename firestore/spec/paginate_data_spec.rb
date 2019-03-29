require_relative "../get_data.rb"
require_relative "../paginate_data.rb"
require_relative "helpers.rb"
require "rspec"
require "rspec/retry"

RSpec.configure do |config|
  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # set retry count and retry sleep interval to 5 seconds
  config.default_retry_count = 5
  config.default_sleep_interval = 5
end

describe "Google Cloud Firestore API samples - Paginate Data" do
  before do
    @firestore_project = ENV["FIRESTORE_PROJECT_ID"]
    retrieve_create_examples project_id: @firestore_project
  end

  after do
    delete_collection_test collection_name: "cities", project_id: ENV["FIRESTORE_PROJECT_ID"]
  end

  # Capture and return STDOUT output by block
  def capture
    real_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = real_stdout
  end

  example "start_at_field_query_cursor" do
    output = capture do
      start_at_field_query_cursor project_id: @firestore_project
    end
    expect(output).to include "Document LA returned by start at population 1000000 field query cursor."
    expect(output).to include "Document TOK returned by start at population 1000000 field query cursor."
    expect(output).to include "Document BJ returned by start at population 1000000 field query cursor."
    expect(output).not_to include "Document SF returned by start at population 1000000 field query cursor."
    expect(output).not_to include "Document DC returned by start at population 1000000 field query cursor."
  end

  example "end_at_field_query_cursor" do
    output = capture do
      end_at_field_query_cursor project_id: @firestore_project
    end
    expect(output).to include "Document DC returned by end at population 1000000 field query cursor."
    expect(output).to include "Document SF returned by end at population 1000000 field query cursor."
    expect(output).not_to include "Document LA returned by end at population 1000000 field query cursor."
    expect(output).not_to include "Document TOK returned by end at population 1000000 field query cursor."
    expect(output).not_to include "Document BJ returned by end at population 1000000 field query cursor."
  end

  example "paginated_query_cursor" do
    output = capture do
      paginated_query_cursor project_id: @firestore_project
    end
    expect(output).not_to include "Document DC returned by paginated query cursor."
    expect(output).not_to include "Document SF returned by paginated query cursor."
    expect(output).not_to include "Document LA returned by paginated query cursor."
    expect(output).to include "Document TOK returned by paginated query cursor."
    expect(output).to include "Document BJ returned by paginated query cursor."
  end

  example "multiple_cursor_conditions" do
    output = capture do
      multiple_cursor_conditions project_id: @firestore_project
    end
    expect(output).not_to include "Document BJ returned by start at Springfield query."
    expect(output).not_to include "Document LA returned by start at Springfield query."
    expect(output).not_to include "Document SF returned by start at Springfield query."
    expect(output).to include "Document TOK returned by start at Springfield query."
    expect(output).to include "Document DC returned by start at Springfield query."
  end
end
