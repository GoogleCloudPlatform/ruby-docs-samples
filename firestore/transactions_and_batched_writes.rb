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

# [START fs_run_simple_transaction]
def run_simple_transaction project_id:
  # project_id = "Your Google Cloud Project ID"
  firestore = Google::Cloud::Firestore.new(project_id: project_id)
  city_ref = firestore.doc "cities/SF"
  firestore.transaction do |tx|
    new_population = tx.get(city_ref).data[:population] + 1
    puts "New population is #{new_population}."
    tx.update(city_ref, { population: new_population})
  end
  puts "Ran a simple transaction to update the population field in the SF document in the cities collection."
end
# [END fs_run_simple_transaction]

# [START fs_return_info_transaction]
def return_info_transaction project_id:
  # project_id = "Your Google Cloud Project ID"
  updated = nil
  firestore = Google::Cloud::Firestore.new(project_id: project_id)
  city_ref = firestore.doc "cities/SF"
  firestore.transaction do |tx|
    new_population = tx.get(city_ref).data[:population] + 1
    if new_population < 1000000
      tx.update(city_ref, { population: new_population})
      updated = true
    else
      updated = false
    end
  end
  updated
end

def return_info_transaction_wrapper project_id:
  result = return_info_transaction project_id: project_id
  if result
    puts "Population updated!"
  else
    puts "Sorry! Population is too big."
  end
end
# [END fs_return_info_transaction]

def batch_write project_id:
  # project_id = "Your Google Cloud Project ID"
  firestore = Google::Cloud::Firestore.new(project_id: project_id)
  # [START fs_batch_write]
  firestore.batch do |b|
    # Set the data for NYC
    b.set("cities/NYC", { name: "New York City" })

    # Update the population for SF
    b.update("cities/SF", { population: 1000000 })

    # Delete LA
    b.delete("cities/LA")
  end
  # [END fs_batch_write]
  puts "Batch write successfully completed."
end



if __FILE__ == $0
  case ARGV.shift
  when "run_simple_transaction"
    run_simple_transaction project_id: ENV["GOOGLE_CLOUD_PROJECT"]
  when "return_info_transaction"
    return_info_transaction_wrapper project_id: ENV["GOOGLE_CLOUD_PROJECT"]
  when "batch_write"
    batch_write project_id: ENV["GOOGLE_CLOUD_PROJECT"]
  else
    puts "Command not found!"
  end
end
