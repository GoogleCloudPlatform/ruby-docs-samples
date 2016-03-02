require "sinatra"

memcached_address = ENV["MEMCACHE_PORT_11211_TCP_ADDR"] || "localhost"
memcached_port    = ENV["MEMCACHE_PORT_11211_TCP_PORT"] || 11211

memcached = Dalli::Client.new "#{memcached_address}:#{memcached_port}"

# Set initial value of counter
memcached.set "counter", 0, nil, raw: true

get "/" do
  value = memcached.incr "counter", 1

  "Counter value is #{value}"
end
