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

# Sample gRPC server that implements the Greeter::Helloworld service.

GRPC_LIBRARY = File.join __dir__, "lib"
$LOAD_PATH.unshift GRPC_LIBRARY unless $LOAD_PATH.include? GRPC_LIBRARY

require "grpc"
require "helloworld_services_pb"

# GreeterServer is simple server that implements the Helloworld Greeter server.
class GreeterServer < Helloworld::Greeter::Service
  # say_hello implements the SayHello rpc method.
  def say_hello hello_request, _unused_call
    Helloworld::HelloReply.new message: "Hello #{hello_request.name}"
  end
end

# main starts an RpcServer that receives requests to GreeterServer at the sample
# server port.
SERVER_ADDRESS = "0.0.0.0:50051".freeze

def main
  puts "Starting HelloWorld server using #{SERVER_ADDRESS}"

  rpc_server = GRPC::RpcServer.new
  rpc_server.add_http2_port SERVER_ADDRESS, :this_port_is_insecure
  rpc_server.handle GreeterServer
  rpc_server.run_till_terminated
end

if $PROGRAM_NAME == __FILE__
  main
end
