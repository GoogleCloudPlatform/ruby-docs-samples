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

def create_note(note_id, project_id)
  # [START containeranalysis_create_note]
  # note_id    = "A user-specified identifier for the note"
  # project_id = "Your Google Cloud project ID"

  require "google/cloud/devtools/containeranalysis"
  containerAnalysis = Google::Cloud::Devtools::Containeranalysis

  # Initialize the client
  grafeas_v1_beta1_client = containerAnalysis::GrafeasV1Beta1.new(version: :v1beta1)

  formatted_parent = containerAnalysis::V1beta1::GrafeasV1Beta1Client.project_path(project_id)
  note = {vulnerability: {}}
  response = grafeas_v1_beta1_client.create_note(formatted_parent, note_id, note)
  ## [END containeranalysis_create_note]
  return response
end

def delete_note(note_id, project_id)
  # [START containeranalysis_delete_note]
  # note_id    = "The identifier for the note to delete"
  # project_id = "The Google Cloud project ID of the note to delete"

  require "google/cloud/devtools/containeranalysis"
  containerAnalysis = Google::Cloud::Devtools::Containeranalysis

  # Initialize the client
  grafeas_v1_beta1_client = containerAnalysis::GrafeasV1Beta1.new(version: :v1beta1)

  formatted_parent = containerAnalysis::V1beta1::GrafeasV1Beta1Client.note_path(project_id, note_id)
  response = grafeas_v1_beta1_client.delete_note(formatted_parent)
  # [END containeranalysis_delete_note]
  return response
end

def create_occurrence(resource_url, note_id, occurrence_project, note_project)
  # [START containeranalysis_create_occurrence]
  # resource_url       = "The URL of the resource associated with the occurrence, eg. https://gcr.io/project/image@sha256:123"
  # note_id            = "The identifier of the note associated with the occurrence"
  # occurrence_project = "The Google Cloud project ID for the new occurrence"
  # note_project       = "The Google Cloud project ID of the associated note"

  require "google/cloud/devtools/containeranalysis"
  containerAnalysis = Google::Cloud::Devtools::Containeranalysis

  # Initialize the client
  grafeas_v1_beta1_client = containerAnalysis::GrafeasV1Beta1.new(version: :v1beta1)
  formatted_note = containerAnalysis::V1beta1::GrafeasV1Beta1Client.note_path(note_project, note_id)
  formatted_occurrence_project = containerAnalysis::V1beta1::GrafeasV1Beta1Client.project_path(occurrence_project)

  occurrence = {note_name: formatted_note, vulnerability: {}, resource:{uri: resource_url}}

  response = grafeas_v1_beta1_client.create_occurrence(formatted_occurrence_project, occurrence)
  # [END containeranalysis_create_occurrence]
  return response
end

def delete_occurrence(occurrence_id, project_id)
  # [START containeranalysis_delete_occurrence]
  # occurrence_id = "The API-generated identifier associated with the occurrence"
  # project_id    = "The Google Cloud project ID of the occurrence to delete"

  require "google/cloud/devtools/containeranalysis"
  containerAnalysis = Google::Cloud::Devtools::Containeranalysis

  # Initialize the client
  grafeas_v1_beta1_client = containerAnalysis::GrafeasV1Beta1.new(version: :v1beta1)

  formatted_parent = containerAnalysis::V1beta1::GrafeasV1Beta1Client.occurrence_path(project_id, occurrence_id)
  grafeas_v1_beta1_client.delete_occurrence(formatted_parent)
  # [END containeranalysis_delete_occurrence]
end


def get_note(note_id, project_id)
  # [START containeranalysis_get_note]
  # note_id    = "The identifier for the note to retrieve"
  # project_id = "The Google Cloud project ID of the note to retrieve"

  require "google/cloud/devtools/containeranalysis"
  containerAnalysis = Google::Cloud::Devtools::Containeranalysis

  # Initialize the client
  grafeas_v1_beta1_client = containerAnalysis::GrafeasV1Beta1.new(version: :v1beta1)

  formatted_note = containerAnalysis::V1beta1::GrafeasV1Beta1Client.note_path(project_id, note_id)
  response = grafeas_v1_beta1_client.get_note(formatted_note)
  # [END containeranalysis_get_note]
  return response
end

def get_occurrence(occurrence_id, project_id)
  # [START containeranalysis_get_occurrence]
  # occurrence_id = "The API-generated identifier associated with the occurrence"
  # project_id    = "The Google Cloud project ID of the occurrence to retrieve"

  require "google/cloud/devtools/containeranalysis"
  containerAnalysis = Google::Cloud::Devtools::Containeranalysis

  # Initialize the client
  grafeas_v1_beta1_client = containerAnalysis::GrafeasV1Beta1.new(version: :v1beta1)

  formatted_parent = containerAnalysis::V1beta1::GrafeasV1Beta1Client.occurrence_path(project_id, occurrence_id)
  response = grafeas_v1_beta1_client.get_occurrence(formatted_parent)
  # [END containeranalysis_get_occurrence]
  return response
end

def get_occurrences_for_image(resource_url, project_id)
  # [START containeranalysis_occurrences_for_image]
  # Initialize the client
  # resource_url = "The URL of the resource associated with the occurrence, eg. https://gcr.io/project/image@sha256:123"
  # project_id    = "The Google Cloud project ID of the occurrences to retrieve"

  require "google/cloud/devtools/containeranalysis"
  containerAnalysis = Google::Cloud::Devtools::Containeranalysis

  # Initialize the client
  grafeas_v1_beta1_client = containerAnalysis::GrafeasV1Beta1.new(version: :v1beta1)

  formatted_parent = containerAnalysis::V1beta1::GrafeasV1Beta1Client.project_path(project_id)
  filter = "resourceUrl = \"#{resource_url}\""
  count = 0
  grafeas_v1_beta1_client.list_occurrences(formatted_parent, filter:filter).each do |occurrence|
     # Process occurrence here
     puts occurrence
     count = count + 1
  end
  puts "Found #{count} occurrences"
  # [END containeranalysis_occurrences_for_image]
  return count
end

def get_occurrences_for_note(note_id, project_id)
  # [START containeranalysis_occurrences_for_note]
  # note_id    = "The identifier for the note to query"
  # project_id = "The Google Cloud project ID of the occurrences to retrieve"

  require "google/cloud/devtools/containeranalysis"
  containerAnalysis = Google::Cloud::Devtools::Containeranalysis

  # Initialize the client
  grafeas_v1_beta1_client = containerAnalysis::GrafeasV1Beta1.new(version: :v1beta1)

  formatted_note = containerAnalysis::V1beta1::GrafeasV1Beta1Client.note_path(project_id, note_id)
  count = 0
  grafeas_v1_beta1_client.list_note_occurrences(formatted_note).each do |occurrence|
     # Process occurrence here
     puts occurrence
     count = count + 1
  end
  puts "Found #{count} occurrences"
  # [END containeranalysis_occurrences_for_image]
  return count
end

def get_discovery_info(resource_url, project_id)
  # [START containeranalysis_discovery_info]
  # resource_url = "The URL of the resource associated with the occurrence, eg. https://gcr.io/project/image@sha256:123"
  # project_id   = "The Google Cloud project ID of the occurrences to retrieve"

  require "google/cloud/devtools/containeranalysis"
  containerAnalysis = Google::Cloud::Devtools::Containeranalysis

  # Initialize the client
  grafeas_v1_beta1_client = containerAnalysis::GrafeasV1Beta1.new(version: :v1beta1)

  formatted_parent = containerAnalysis::V1beta1::GrafeasV1Beta1Client.project_path(project_id)
  filter = "kind = \"DISCOVERY\" AND resourceUrl = \"#{resource_url}\""
  grafeas_v1_beta1_client.list_occurrences(formatted_parent, filter:filter).each do |occurrence|
     # Process discovery occurrence here
     puts occurrence
  end
  # [END containeranalysis_discovery_info]
end

def occurrence_pubsub(subscription_id, timeout_seconds, project_id)
  # [START containeranalysis_pubsub]
  # subscription_id = "A user-specified identifier for the new subscription"
  # timeout_seconds = "The number of seconds to listen for new Pub/Sub messages"
  # project_id      = "Your Google Cloud project ID"

  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id
  topic = pubsub.topic "container-analysis-occurrences-v1beta1"
  subscription = topic.subscribe subscription_id

  count = 0
  subscriber = subscription.listen do |received_message|
    count += 1
    # Process incoming occurrence here
    puts "Message #{count}: #{received_message.data}"
    received_message.acknowledge!
  end
  subscriber.start
  # Wait for incomming occurrences
  sleep timeout_seconds
  subscriber.stop.wait!
  subscription.delete
  # Print and return the total number of Pub/Sub messages received
  puts "Total Messges Received: #{count}"
  return count
  # [END containeranalysis_pubsub]
end

def poll_discovery_finished(resource_url, timeout_seconds, project_id)
  # [START containeranalysis_poll_discovery_occurrence_finished]
  # resource_url    = "The URL of the resource associated with the occurrence, eg. https://gcr.io/project/image@sha256:123"
  # timeout_seconds = "The number of seconds to wait for the discovery occurrence"
  # project_id      = "Your Google Cloud project ID"

  require "google/cloud/devtools/containeranalysis"
  containerAnalysis = Google::Cloud::Devtools::Containeranalysis

  deadline = Time.now + timeout_seconds

  # Initialize the client
  grafeas_v1_beta1_client = containerAnalysis::GrafeasV1Beta1.new(version: :v1beta1)
  formatted_parent = containerAnalysis::V1beta1::GrafeasV1Beta1Client.project_path(project_id)

  # Find the discovery occurrence using a filter string
  discovery_occurrence = nil
  while discovery_occurrence == nil do
    begin
      filter = "resourceUrl=\"#{resource_url}\" AND noteProjectId=\"goog-analysis\" AND noteId=\"PACKAGE_VULNERABILITY\""
      # [END containeranalysis_poll_discovery_occurrence_finished]i
      # The above filter isn't testable, since it looks for occurrences in a locked down project
      # Fall back to a more permissive filter for testing
      filter = "kind = \"DISCOVERY\" AND resourceUrl = \"#{resource_url}\""
      # [START containeranalysis_poll_discovery_occurrence_finished]
      # Only the discovery occurrence should be returned for the given filter
      discovery_occurrence = grafeas_v1_beta1_client.list_occurrences(formatted_parent, filter:filter).first
    rescue StandardError # If there is an error, keep trying until the timeout deadline
    ensure
      # check for timeout
      sleep 1
      if Time.now > deadline
        raise RuntimeError, 'Timeout while retrieving discovery occurrence.'
      end
    end
  end

  # Wait for the discovery occurrence to enter a terminal state
  status = Grafeas::V1beta1::Discovery::Discovered::AnalysisStatus::PENDING
  while (status != :FINISHED_SUCCESS && status != :FINISHED_FAILED && status != :FINISHED_UNSUPPORTED) do
    # Update occurrence
    begin
      updated = grafeas_v1_beta1_client.get_occurrence(discovery_occurrence.name)
      status = updated.discovered.discovered.analysis_status
    rescue StandardError # If there is an error, keep trying until the timeout deadline
    ensure
      # check for timeout
      sleep 1
      if Time.now > deadline
        raise RuntimeError, 'Timeout while retrieving discovery occurrence.'
      end
    end
  end
  puts "Found discovery occurrence #{updated.name}. Status: #{updated.discovered.discovered.analysis_status}"
  # [END containeranalysis_poll_discovery_occurrence_finished]
  return updated
end

def find_vulnerabilities_for_image(resource_url, project_id)
  # [START containeranalysis_vulnerability_occurrences_for_image]
  # resource_url = "The URL of the resource associated with the occurrence, eg. https://gcr.io/project/image@sha256:123"
  # project_id   = "The Google Cloud project ID of the vulnerabilities to retrieve"

  require "google/cloud/devtools/containeranalysis"
  containerAnalysis = Google::Cloud::Devtools::Containeranalysis

  # Initialize the client
  grafeas_v1_beta1_client = containerAnalysis::GrafeasV1Beta1.new(version: :v1beta1)

  formatted_parent = containerAnalysis::V1beta1::GrafeasV1Beta1Client.project_path(project_id)
  filter = "resourceUrl = \"#{resource_url}\" AND kind = \"VULNERABILITY\""
  occurrence_list = grafeas_v1_beta1_client.list_occurrences(formatted_parent, filter:filter)
  # [END containeranalysis_vulnerability_occurrences_for_image]
  return occurrence_list
end

def find_high_severity_vulnerabilities_for_image(resource_url, project_id)
  # [START containeranalysis_filter_vulnerability_occurrences]
  # resource_url = "The URL of the resource associated with the occurrence, eg. https://gcr.io/project/image@sha256:123"
  # project_id   = "The Google Cloud project ID of the vulnerabilities to retrieve"

  require "google/cloud/devtools/containeranalysis"
  containerAnalysis = Google::Cloud::Devtools::Containeranalysis

  # Initialize the client
  grafeas_v1_beta1_client = containerAnalysis::GrafeasV1Beta1.new(version: :v1beta1)

  formatted_parent = containerAnalysis::V1beta1::GrafeasV1Beta1Client.project_path(project_id)
  filter = "resourceUrl = \"#{resource_url}\" AND kind = \"VULNERABILITY\""
  vulnerability_list = grafeas_v1_beta1_client.list_occurrences(formatted_parent, filter: filter)
  # Filter the list to include only "high" and "critical" vulnerabilities
  vulnerability_list.select do |item|
    item.vulnerability.severity == :HIGH ||
      item.vulnerability.severity == :CRITICAL
  end
  # [END containeranalysis_filter_vulnerability_occurrences]
end
