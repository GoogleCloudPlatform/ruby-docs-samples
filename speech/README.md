# Google Cloud Speech API Ruby Samples

## Notes

### Generating REST API client

     generate-api gen speech --url=https://www.googleapis.com/discovery/v1/apis/speech/v1beta1/rest

### Generating gRPC API client

    # git clone https://github.com/googleapis/googleapis.git
    # export PROTOS_PATH="/path/to/googleapis/"

    mkdir lib
    grpc_tools_ruby_protoc -I $PROTOS_PATH --ruby_out=lib --grpc_out=lib $PROTOS_PATH/google/cloud/speech/v1/cloud_speech.proto


<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Speech API Ruby Samples

[Sign up for the Alpha](https://services.google.com/fb/forms/speech-api-alpha/).

The [Cloud Speech API](https://cloud.google.com/speech/) enables easy
integration of Google speech recognition technologies into developer applications.

## Samples

Before running the samples below, first install dependencies:

    bundle install

### REST API

To run a sample that uses the Cloud Speech REST API:

```sh
bundle exec ruby recognize.rb audio_files/audio.raw
```

### gRPC API

To run a sample that uses the Cloud Speech gRPC API:

```sh
bundle exec ruby grpc_recognize.rb audio_files/audio.raw
bundle exec ruby grpc_recognize.rb "gs://bucket/audio.raw"
```
