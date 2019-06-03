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

$LOAD_PATH.unshift('./google-cloud-containeranalysis/lib')
require "google/cloud/devtools/containeranalysis"
require_relative "../sample"
require "rspec"
require "google/gax/grpc"
require "pathname"
require 'securerandom'

ContainerAnalysis = Google::Cloud::Devtools::Containeranalysis

describe "Container Analysis API samples" do
  let(:client) { ContainerAnalysis::GrafeasV1Beta1.new(version: :v1beta1) }

  before do |example|
    test_name = example.description.tr(' ', '-')
    uuid = SecureRandom.uuid
    @note_id = "note-" + uuid + "-" + test_name
    @image_url = "https://gcr.io/" + test_name + "/" + uuid
    @project_id = "sanche-testing-project"
    @note_obj = create_note(@note_id, @project_id)
    @try_limit = 10
    @sleep_time = 1
    @subscription_id = "occurrence-subscription-" + uuid
    @uuid = uuid
  end

  after do
    begin
      delete_note(@note_id, @project_id)
    rescue
    end
  end

  example "test create note" do
    # note should be created as part of set up. verify that it succeeded
    result_note = get_note(@note_id, @project_id)
    expect(result_note.name).to eq(@note_obj.name)
  end

  example "test delete note" do
    delete_note(@note_id, @project_id)
    begin
      get_note(@note_id, @project_id)
      # get_note should throw exception. Test fails
      assert(false)
    rescue Google::Gax::RetryError
      puts "rescued"
      # test passes
    end
  end

  example "test create occurrence" do
    result = create_occurrence(@image_url, @note_id, @project_id, @project_id)
    expect(result).not_to be_nil
    expect(result.resource.uri).to eq(@image_url)

    occurrence_id = Pathname.new(result.name).basename.to_s
    retrieved = get_occurrence(occurrence_id, @project_id)
    expect(retrieved).not_to be_nil
    expect(retrieved.name).to eq(result.name)
  end

  example "test delete occurrence" do
    created = create_occurrence(@image_url, @note_id, @project_id, @project_id)

    occurrence_id = Pathname.new(created.name).basename.to_s
    delete_occurrence(occurrence_id, @project_id)
    begin
      get_occurrence(occurrence_id, @project_id)
      # get_occurrence should throw exception on deleted occurrence. Test fails
      assert(false)
    rescue Google::Gax::RetryError
      puts "rescued"
      # test passes
    end
  end

  example "test occurrences for image" do
    count = get_occurrences_for_image(@image_url, @project_id)
    expect(count).to eq(0)

    create_occurrence(@image_url, @note_id, @project_id, @project_id)
    try = 0
    while count != 1 and try < @try_limit
      sleep @sleep_time
      count = get_occurrences_for_image(@image_url, @project_id)
      try += 1
    end
    expect(count).to eq(1)
  end

  example "test occurrences for note" do
    count = get_occurrences_for_note(@note_id, @project_id)
    expect(count).to eq(0)

    create_occurrence(@image_url, @note_id, @project_id, @project_id)
    try = 0
    while count != 1 and try < @try_limit
      sleep @sleep_time
      count = get_occurrences_for_note(@note_id, @project_id)
      try += 1
    end
    expect(count).to eq(1)
  end

  example "test occurrence pubsub" do
    try = 0
    count = -1
    # empty the pubsub queue
    while count != 0 and try < @try_limit
      count = occurrence_pubsub(@subscription_id, 5, @project_id)
      try += 1
    end
    expect(count).to eq(0)

    # test pubsub while creating occurrences
    try = 0
    total_num = 3
    while count != total_num and try < @try_limit
      # start the pubsub function listening in its own thread
      t2 = Thread.new{
        Thread.current[:output] = occurrence_pubsub(@subscription_id, (total_num*@sleep_time)+10, @project_id)
      }
      sleep 5
      # create a number of test occurrences
      (1..total_num).each do |counter|
          created = create_occurrence(@image_url, @note_id, @project_id, @project_id)
          sleep @sleep_time
          occurrence_id = Pathname.new(created.name).basename.to_s
          delete_occurrence(occurrence_id, @project_id)
      end
      # check to ensure the numbers match
      t2.join
      count = t2[:output]
    end
    expect(count).to eq(total_num)
  end

  example "test polling discovery occurrence" do
    begin
      poll_discovery_finished(@image_url, 5, @project_id)
      # expect poll to fil when resource has no discovery occurrence
      assert(false)
    rescue RuntimeError
      puts "rescued"
      # test passes
    end

    # create discovery occurrence
    note_id = "discovery-note-" + @uuid
    grafeas_v1_beta1_client = ContainerAnalysis::GrafeasV1Beta1.new(version: :v1beta1)
    formatted_project = ContainerAnalysis::V1beta1::GrafeasV1Beta1Client.project_path(@project_id)
    note = {discovery: {}}
    grafeas_v1_beta1_client.create_note(formatted_project, note_id, note)
    formatted_note = ContainerAnalysis::V1beta1::GrafeasV1Beta1Client.note_path(@project_id, note_id)
    occurrence = {note_name: formatted_note, 
                  discovered: {
                    discovered: {analysis_status: :FINISHED_SUCCESS}, 
                  },
                  resource:{uri: @image_url}}
    created = grafeas_v1_beta1_client.create_occurrence(formatted_project, occurrence)

    # poll again
    found = poll_discovery_finished(@image_url, 5, @project_id)
    expect(found.name).to eq(created.name)
    expect(found.discovered.discovered.analysis_status).to eq(:FINISHED_SUCCESS)

    # clean up
    occurrence_id = Pathname.new(created.name).basename.to_s
    delete_occurrence(occurrence_id, @project_id)
    delete_note(note_id, @project_id)
  end

  example "test find vulnerabilities" do
    result_list = find_vulnerabilities_for_image(@image_url, @project_id)
    c = result_list.count
    expect(c).to eq(0)

    # create vulnerability occurrence
    create_occurrence(@image_url, @note_id, @project_id, @project_id)
    try = 0
    while c != 1 and try < @try_limit
      sleep @sleep_time
      result_list = find_vulnerabilities_for_image(@image_url, @project_id)
      c = result_list.count
      try += 1
    end
    expect(result_list.count).to eq(1)
  end

  example "test find high severity vulnerabilities" do
    result_list = find_high_severity_vulnerabilities_for_image(@image_url, @project_id)
    sleep 1
    expect(result_list.count).to eq(0)
 
    # create vulnerability occurrence
    create_occurrence(@image_url, @note_id, @project_id, @project_id)
    result_list = find_high_severity_vulnerabilities_for_image(@image_url, @project_id)
    sleep 1
    expect(result_list.count).to eq(0)

    # create critical secerity occurrence
    note_id = "severe-note-" + @uuid
    grafeas_v1_beta1_client = ContainerAnalysis::GrafeasV1Beta1.new(version: :v1beta1)
    formatted_project = ContainerAnalysis::V1beta1::GrafeasV1Beta1Client.project_path(@project_id)
    note = {vulnerability: {severity: :CRITICAL}}
    grafeas_v1_beta1_client.create_note(formatted_project, note_id, note)
    formatted_note = ContainerAnalysis::V1beta1::GrafeasV1Beta1Client.note_path(@project_id, note_id)
    occurrence = {note_name: formatted_note, 
                  vulnerability: {severity: :CRITICAL},
                  resource:{uri: @image_url}}
    grafeas_v1_beta1_client.create_occurrence(formatted_project, occurrence)

    # try again
    try = 0
    c = 0
    while c != 1 and try < @try_limit
      sleep @sleep_time
      result_list = find_high_severity_vulnerabilities_for_image(@image_url, @project_id)
      c = result_list.count
      try += 1
    end
    expect(result_list.count).to eq(1)
  end
end
