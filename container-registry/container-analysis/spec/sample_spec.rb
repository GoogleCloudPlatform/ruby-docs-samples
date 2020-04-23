# Copyright 2019 Google LLC
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

require "grafeas"
require_relative "../sample"
require "rspec"
require "google/cloud/pubsub"
require "google/gax/grpc"
require "pathname"
require 'securerandom'

describe "Container Analysis API samples" do
  let(:client) { Grafeas.new(version: :v1) }

  before do |example|
    test_name = example.description.tr(' ', '-')
    uuid = SecureRandom.uuid
    @note_id = "note-" + uuid + "-" + test_name
    @image_url = "https://gcr.io/" + test_name + "/" + uuid
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    @note_obj = create_note project_id: @project_id, note_id: @note_id
    @try_limit = 10
    @sleep_time = 1
    @subscription_id = "occurrence-subscription-" + uuid
    @uuid = uuid
  end

  after do
    begin
      delete_note project_id: @project_id, note_id: @note_id
    rescue
    end
  end

  example "test create note" do
    # note should be created as part of set up. verify that it succeeded
    result_note = get_note project_id: @project_id, note_id: @note_id
    expect(result_note.name).to eq(@note_obj.name)
  end

  example "test delete note" do
    delete_note project_id: @project_id, note_id: @note_id
    begin
      get_note project_id: @project_id, note_id: @note_id
      # get_note should throw exception. Test fails
      assert(false)
    rescue Google::Gax::RetryError
      puts "rescued"
      # test passes
    end
  end

  example "test create occurrence" do
    result = create_occurrence resource_url: @image_url, 
                               note_id: @note_id,
                               occurrence_project: @project_id,
                               note_project: @project_id
    expect(result).not_to be_nil
    expect(result.resource_uri).to eq(@image_url)

    occurrence_id = Pathname.new(result.name).basename.to_s
    retrieved = get_occurrence occurrence_id: occurrence_id, project_id: @project_id
    expect(retrieved).not_to be_nil
    expect(retrieved.name).to eq(result.name)
  end

  example "test delete occurrence" do
    created = create_occurrence resource_url: @image_url, 
                                note_id: @note_id,
                                occurrence_project: @project_id,
                                note_project: @project_id
    occurrence_id = Pathname.new(created.name).basename.to_s
    delete_occurrence occurrence_id: occurrence_id, project_id: @project_id
    begin
      get_occurrence occurrence_id: occurrence_id, project_id: @project_id
      # get_occurrence should throw exception on deleted occurrence. Test fails
      assert(false)
    rescue Google::Gax::RetryError
      puts "rescued"
      # test passes
    end
  end

  example "test occurrences for image" do
    count = get_occurrences_for_image resource_url: @image_url, project_id: @project_id
    expect(count).to eq(0)

    create_occurrence resource_url: @image_url, 
                      note_id: @note_id,
                      occurrence_project: @project_id,
                      note_project: @project_id
    try = 0
    while count != 1 and try < @try_limit
      sleep @sleep_time
      count = get_occurrences_for_image resource_url: @image_url, project_id: @project_id
      try += 1
    end
    expect(count).to eq(1)
  end

  example "test occurrences for note" do
    count = get_occurrences_for_note note_id: @note_id, project_id: @project_id
    expect(count).to eq(0)

    create_occurrence resource_url: @image_url, 
                      note_id: @note_id,
                      occurrence_project: @project_id,
                      note_project: @project_id
    try = 0
    while count != 1 and try < @try_limit
      sleep @sleep_time
      count = get_occurrences_for_note note_id: @note_id, project_id: @project_id
      try += 1
    end
    expect(count).to eq(1)
  end

  example "test occurrence pubsub" do
    # create topic if needed
    pubsub = Google::Cloud::Pubsub.new project: @project_id
    topic_name = "container-analysis-occurrences-v1"
    topic = pubsub.topic topic_name
    if not topic or not topic.exists?
      pubsub.create_topic topic_name
    end

    try = 0
    count = -1
    # empty the pubsub queue
    while count != 0 and try < @try_limit
      count = occurrence_pubsub subscription_id: @subscription_id, timeout_seconds: 5, project_id: @project_id
      try += 1
    end
    expect(count).to eq(0)

    # test pubsub while creating occurrences
    try = 0
    total_num = 3
    while count != total_num and try < @try_limit
      # start the pubsub function listening in its own thread
      t2 = Thread.new{
        Thread.current[:output] = occurrence_pubsub subscription_id: @subscription_id, 
                                                    timeout_seconds: (total_num*@sleep_time)+10,
                                                    project_id: @project_id
      }
      sleep 5
      # create a number of test occurrences
      (1..total_num).each do |counter|
          created = create_occurrence resource_url: @image_url, 
                                      note_id: @note_id,
                                      occurrence_project: @project_id,
                                      note_project: @project_id
          sleep @sleep_time
          occurrence_id = Pathname.new(created.name).basename.to_s
          delete_occurrence occurrence_id: occurrence_id, project_id: @project_id
      end
      # check to ensure the numbers match
      t2.join
      count = t2[:output]
    end
    expect(count).to eq(total_num)
  end

  example "test polling discovery occurrence" do
    begin
      poll_discovery_finished resource_url: @image_url,
                              project_id: @project_id,
                              timeout_seconds: 5
      # expect poll to fil when resource has no discovery occurrence
      assert(false)
    rescue RuntimeError
      puts "rescued"
      # test passes
    end

    # create discovery occurrence
    note_id = "discovery-note-" + @uuid
    formatted_project = Grafeas::V1::GrafeasClient.project_path(@project_id)
    note = {discovery: {analysis_kind: :DISCOVERY}}
    client.create_note(formatted_project, note_id, note)
    formatted_note = Grafeas::V1::GrafeasClient.note_path(@project_id, note_id)
    occurrence = {
      note_name: formatted_note,
      resource_uri: @image_url,
      discovery: {
        analysis_status: :FINISHED_SUCCESS,
      },
    }
    created = client.create_occurrence(formatted_project, occurrence)


    # poll again
    found = poll_discovery_finished resource_url: @image_url,
                                    project_id: @project_id,
                                    timeout_seconds: 5
    expect(found.name).to eq(created.name)
    expect(found.discovery.analysis_status).to eq(:FINISHED_SUCCESS)

    # clean up
    occurrence_id = Pathname.new(created.name).basename.to_s
    delete_occurrence occurrence_id: occurrence_id, project_id: @project_id
    delete_note project_id: @project_id, note_id: note_id
  end

  example "test find vulnerabilities" do
    result_list = find_vulnerabilities_for_image resource_url: @image_url, project_id: @project_id
    c = result_list.count
    expect(c).to eq(0)

    # create vulnerability occurrence
    create_occurrence resource_url: @image_url, 
                      note_id: @note_id,
                      occurrence_project: @project_id,
                      note_project: @project_id
    try = 0
    while c != 1 and try < @try_limit
      sleep @sleep_time
      result_list = find_vulnerabilities_for_image resource_url: @image_url, project_id: @project_id
      c = result_list.count
      try += 1
    end
    expect(result_list.count).to eq(1)
  end

  example "test find high severity vulnerabilities" do
    result_list = find_high_severity_vulnerabilities_for_image resource_url: @image_url, project_id: @project_id
    sleep 1
    expect(result_list.count).to eq(0)
 
    # create vulnerability occurrence
    create_occurrence resource_url: @image_url, 
                      note_id: @note_id,
                      occurrence_project: @project_id,
                      note_project: @project_id
    result_list = find_high_severity_vulnerabilities_for_image resource_url: @image_url, project_id: @project_id
    sleep 1
    expect(result_list.count).to eq(0)

    # create critical secerity occurrence
    note_id = "severe-note-" + @uuid
    formatted_project = Grafeas::V1::GrafeasClient.project_path(@project_id)
    note = {vulnerability: {severity: :CRITICAL}}
    note = { 
      vulnerability: {
        severity: :CRITICAL,
        details: [
            affected_cpe_uri: 'your-uri-here',
            affected_package: 'your-package-here',
            min_affected_version: { kind: Grafeas::V1::Version::VersionKind::MINIMUM },
            fixed_version: { kind: Grafeas::V1::Version::VersionKind::MAXIMUM }
          ],
        } 
      }
    client.create_note(formatted_project, note_id, note)
    formatted_note = Grafeas::V1::GrafeasClient.note_path(@project_id, note_id)
    occurrence = {note_name: formatted_note, 
                  vulnerability: {severity: :CRITICAL},
                  resource:{uri: @image_url}}
    occurrence = { 
      note_name:     formatted_note,
      resource_uri: @image_url,
      vulnerability: {
        effective_severity: :CRITICAL,
        package_issue: [
          affected_cpe_uri: 'your-uri-here',
          affected_package: 'your-package-here',
          min_affected_version: { kind: Grafeas::V1::Version::VersionKind::MINIMUM },
          fixed_version: { kind: Grafeas::V1::Version::VersionKind::MAXIMUM }
        ]
      }
    }
    client.create_occurrence(formatted_project, occurrence)

    # Retry until we find an image with a high severity vulnerability
    retry_count = 0
    vulnerability_count = 0
    while vulnerability_count != 1 and retry_count < @try_limit
      sleep @sleep_time
      result_list = find_high_severity_vulnerabilities_for_image resource_url: @image_url, project_id: @project_id
      vulnerability_count = result_list.count
      retry_count += 1
    end
    expect(result_list.count).to eq(1)
  end
end
