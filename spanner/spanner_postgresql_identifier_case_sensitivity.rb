# Copyright 2022 Google, Inc
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

# [START spanner_postgresql_identifier_case_sensitivity]
require "google/cloud/spanner"
require "google/cloud/spanner/admin/database"

def spanner_postgresql_identifier_case_sensitivity project_id:, instance_id:, database_id:
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  db_admin_client = Google::Cloud::Spanner::Admin::Database.database_admin project: project_id

  db_path = db_admin_client.database_path project: project_id,
                                          instance: instance_id,
                                          database: database_id

  # ConcertId will be folded to `concertid`.
  # Location and Time are double-quoted and will therefore retain their
  # mixed case and are case-sensitive. This means that any statement that
  # references any of these columns must use double quotes.
  create_concerts_query = <<~QUERY
    CREATE TABLE Concerts (
      ConcertId bigint NOT NULL PRIMARY KEY,
      \"Location\" varchar(1024) NOT NULL,
      \"Time\"  timestamptz NOT NULL
    )
  QUERY


  job = db_admin_client.update_database_ddl database: db_path,
                                            statements: [create_concerts_query]

  job.wait_until_done!

  if job.error?
    puts "Error while updating database. Code: #{job.error.code}. Message: #{job.error.message}"
    raise GRPC::BadStatus.new(job.error.code, job.error.message)
  end

  puts "Created table with case sensitive names in database #{database_id} using PostgreSQL dialect."

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  # PostgreSQL case sensitivity with mutations.
  # Mutations: Column names in mutations are always case-insensitive, regardless whether the
  # columns were double-quoted or not during creation.
  client.commit do |c|
    c.insert "Concerts", [
      { ConcertId: 1, Location: "Venue 1", Time: Time.utc(2022, "Mar", 11) }
    ]
  end

  results = client.execute "SELECT * FROM Concerts"
  results.rows.each do |row|
    # ConcertId was not double quoted while table creation, so it is automatically folded to lower case.
    # Accessing the column by its name in a result set must therefore use all lower-case letters.
    puts "ConcertId: #{row[:concertid]}"

    # Location and Time were double quoted during creation,
    # and retain their mixed case when returned in a result set.
    puts "Location: #{row[:Location]}"
    puts "Time: #{row[:Time]}"
  end

  # PostgreSQL case sensitivity with aliases.
  # Aliases : They are also identifiers, and specifying an alias in double quotes will make the alias retain its case.
  results = client.execute "SELECT concertid AS \"ConcertId\", \"Location\" AS \"venue\", \"Time\" FROM Concerts"
  results.rows.each do |row|
    # The aliases are double-quoted and therefore retains their mixed case.
    puts "ConcertId (double quoted alias): #{row[:ConcertId]}"
    puts "Location (double quoted alias): #{row[:venue]}"
    puts "Time (double quoted): #{row[:Time]}"
  end

  # PostgreSQL case sensitivity with DML statements.
  # DML statements must also follow the PostgreSQL case rules.
  sql_query = "INSERT INTO Concerts (ConcertId, \"Location\", \"Time\") VALUES($1, $2, $3)"
  params = { p1: 2, p2: "Venue 2", p3: Time.utc(2022, "Mar", 11) }
  row_count = nil
  client.transaction do |transaction|
    row_count = transaction.execute_update sql_query, params: params
  end

  puts "Inserted #{row_count} row(s)"
end
# [END spanner_postgresql_identifier_case_sensitivity]

if $PROGRAM_NAME == __FILE__
  spanner_postgresql_identifier_case_sensitivity project_id: ARGV.shift, instance_id: ARGV.shift, database_id: ARGV.shift
end
