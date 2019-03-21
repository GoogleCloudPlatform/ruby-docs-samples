# Copyright 2018 Google, Inc
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

require "google/cloud/firestore"

def query_create_examples project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_query_create_examples]
  cities_ref = firestore.col "cities"
  cities_ref.doc("SF").set(
    name:       "San Francisco",
    state:      "CA",
    country:    "USA",
    capital:    false,
    population: 860_000
  )
  cities_ref.doc("LA").set(
    name:       "Los Angeles",
    state:      "CA",
    country:    "USA",
    capital:    false,
    population: 3_900_000
  )
  cities_ref.doc("DC").set(
    name:       "Washington D.C.",
    state:      nil,
    country:    "USA",
    capital:    true,
    population: 680_000
  )
  cities_ref.doc("TOK").set(
    name:       "Tokyo",
    state:      nil,
    country:    "Japan",
    capital:    true,
    population: 9_000_000
  )
  cities_ref.doc("BJ").set(
    name:       "Beijing",
    state:      nil,
    country:    "China",
    capital:    true,
    population: 21_500_000
  )
  # [END fs_query_create_examples]
  puts "Added example cities data to the cities collection."
end

def create_query_state project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_create_query_state]
  cities_ref = firestore.col "cities"

  query = cities_ref.where "state", "=", "CA"

  query.get do |city|
    puts "Document #{city.document_id} returned by query state=CA."
  end
  # [END fs_create_query_state]
end

def create_query_capital project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_create_query_capital]
  cities_ref = firestore.col "cities"

  query = cities_ref.where "capital", "=", true

  query.get do |city|
    puts "Document #{city.document_id} returned by query capital=true."
  end
  # [END fs_create_query_capital]
end

def simple_queries project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore  = Google::Cloud::Firestore.new project_id: project_id
  cities_ref = firestore.col "cities"
  # [START fs_simple_queries]
  state_query      = cities_ref.where "state", "=", "CA"
  population_query = cities_ref.where "population", ">", 1_000_000
  name_query       = cities_ref.where "name", ">=", "San Francisco"
  # [END fs_simple_queries]
  state_query.get do |city|
    puts "Document #{city.document_id} returned by query state=CA."
  end
  population_query.get do |city|
    puts "Document #{city.document_id} returned by query population>1000000."
  end
  name_query.get do |city|
    puts "Document #{city.document_id} returned by query name>=San Francisco."
  end
end

def chained_query project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore  = Google::Cloud::Firestore.new project_id: project_id
  cities_ref = firestore.col "cities"
  # [START fs_chained_query]
  chained_query = cities_ref.where("state", "=", "CA").where "name", "=", "San Francisco"
  # [END fs_chained_query]
  chained_query.get do |city|
    puts "Document #{city.document_id} returned by query state=CA and name=San Francisco."
  end
end

def composite_index_chained_query project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore  = Google::Cloud::Firestore.new project_id: project_id
  cities_ref = firestore.col "cities"
  # [START fs_composite_index_chained_query]
  chained_query = cities_ref.where("state", "=", "CA").where "population", "<", 1_000_000
  # [END fs_composite_index_chained_query]
  chained_query.get do |city|
    puts "Document #{city.document_id} returned by query state=CA and population<1000000."
  end
end

def range_query project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore  = Google::Cloud::Firestore.new project_id: project_id
  cities_ref = firestore.col "cities"
  # [START fs_range_query]
  range_query = cities_ref.where("state", ">=", "CA").where "state", "<=", "IN"
  # [END fs_range_query]
  range_query.get do |city|
    puts "Document #{city.document_id} returned by query CA<=state<=IN."
  end
end

def invalid_range_query project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore  = Google::Cloud::Firestore.new project_id: project_id
  cities_ref = firestore.col "cities"
  # [START fs_invalid_range_query]
  invalid_range_query = cities_ref.where("state", ">=", "CA").where "population", ">", 1_000_000
  # [END fs_invalid_range_query]
end


if $PROGRAM_NAME == __FILE__
  project = ENV["FIRESTORE_PROJECT_ID"]
  case ARGV.shift
  when "query_create_examples"
    query_create_examples project_id: project
  when "create_query_state"
    create_query_state project_id: project
  when "create_query_capital"
    create_query_capital project_id: project
  when "simple_queries"
    simple_queries project_id: project
  when "chained_query"
    chained_query project_id: project
  when "composite_index_chained_query"
    composite_index_chained_query project_id: project
  when "range_query"
    range_query project_id: project
  when "invalid_range_query"
    invalid_range_query project_id: project
  else
    puts <<~USAGE
      Usage: bundle exec ruby query_data.rb [command]

      Commands:
        query_create_examples          Create an example collection of documents.
        create_query_state             Create a query by state.
        create_query_capital           Create a query by capital.
        simple_queries                 Create simple queries with a single where clause.
        chained_query                  Create a query with chained clauses.
        composite_index_chained_query  Create a composite index chained query.
        range_query                    Create a query with range clauses.
        invalid_range_query            An example of an invalid range query.
    USAGE
  end
end
