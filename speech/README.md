# Google Cloud Speech API Ruby Samples

## Notes

### Generating REST API client

     generate-api gen speech --url=https://www.googleapis.com/discovery/v1/apis/speech/v1beta1/rest

### Generating gRPC API client

    # git clone https://github.com/googleapis/googleapis.git
    # export PROTOS_PATH="/path/to/googleapis/"

    mkdir lib
    grpc_tools_ruby_protoc -I $PROTOS_PATH --ruby_out=lib --grpc_out=lib $PROTOS_PATH/google/cloud/speech/v1/cloud_speech.proto
