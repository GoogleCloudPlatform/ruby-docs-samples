require "digest/sha2"
require "sinatra"
require "sequel"

DB = Sequel.mysql2(
  host:     ENV["MYSQL_HOST"],
  user:     ENV["MYSQL_USER"],
  password: ENV["MYSQL_PASSWORD"],
  database: ENV["MYSQL_DATABASE"]
)

puts([
  host:     ENV["MYSQL_HOST"],
  user:     ENV["MYSQL_USER"],
  password: ENV["MYSQL_PASSWORD"],
  database: ENV["MYSQL_DATABASE"]
].inspect)

unless DB.tables.include? :visits
  DB.create_table "visits" do
    primary_key :id
    String :user_ip
    Time   :timestamp
  end
end

get "/" do
  # Save visit in database
  DB[:visits].insert(
    user_ip:   Digest::SHA256.hexdigest(request.ip),
    timestamp: Time.now
  )

  response.write "Last 10 visits:\n"

  DB[:visits].order(Sequel.desc(:timestamp)).each do |visit|
    response.write "Time: #{visit[:timestamp]} Addr: #{visit[:user_ip]}\n"
  end

  content_type "text/plain"
  status 200
end
