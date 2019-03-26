# Copyright 2017 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in write, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Sample app that connects to a Greeter service.

GRPC_LIBRARY = File.join __dir__, "lib"
$LOAD_PATH.unshift GRPC_LIBRARY unless $LOAD_PATH.include? GRPC_LIBRARY

require "grpc"
require "helloworld_services_pb"

def main host, api_key, user
  stub = Helloworld::Greeter::Stub.new host, :this_channel_is_insecure

  request  = Helloworld::HelloRequest.new name: user
  metadata = { "x-api-key": api_key }
  response = stub.say_hello request, metadata: metadata
  message  = response.message

  puts "Greeting: #{message}"
end

if $PROGRAM_NAME == __FILE__
  if ARGV.size < 2
    puts <<~USAGE
      Usage: bundle exec ruby greeter_client.rb <host> <api_key> [greetee]

      Arguments:
        host                 gRPC host to connect to, ex: localhost:50051
        api_key              API key to add to request
        greetee              Optional, Who to greet
    USAGE
  else
    host    = ARGV.shift
    api_key = ARGV.shift
    user    = ARGV.shift || "world"

    main host, api_key, user
  end
end
