# Endpoints Getting Started with gRPC & Ruby Quickstart

It is assumed that you have a working Ruby environment and a Google
Cloud account and [SDK](https://cloud.google.com/sdk/) configured.

1. Install dependencies:

    ```bash
    bundle
    gem install grpc-tools
    ```

1. Test running the code, optional:

    ```bash
    # In the background or another terminal run the server:
    bundle exec ruby greeter_server.rb

    # Check the client parameters:
    bundle exec ruby greeter_client.rb

    # Run the client
    bundle exec ruby greeter_client.rb localhost:50051 test
    ```

1. The gRPC Services have already been generated in `lib/`. If you
   change the proto, or just wish to regenerate these files, run:

    ```bash
    grpc_tools_ruby_protoc -I protos --ruby_out=lib --grpc_out=lib protos/helloworld.proto
    ```

1. Generate the [file descriptor set][1] `out.pb` from the proto file.

    ```bash
    grpc_tools_ruby_protoc --include_imports --include_source_info protos/helloworld.proto --descriptor_set_out out.pb
    ```

1. Edit, `api_config.yaml`. Replace `MY_PROJECT_ID` with your project id.

1. Deploy your service config to Service Management:

    ```bash
    gcloud endpoints services deploy out.pb api_config.yaml
    # The Config ID should be printed out, looks like: 2017-02-01r0, remember this

    # set your project to make commands easier
    GOOGLE_CLOUD_PROJECT=<Your Project ID>

    # Print out your Service name again, in case you missed it
    gcloud endpoints services configs list --service hellogrpc.endpoints.${GOOGLE_CLOUD_PROJECT}.cloud.goog
    ```

1. Also get an API key from the Console's API Manager for use in the
   client later. (https://console.cloud.google.com/apis/credentials)

1. Build a docker image for your gRPC server, store in your Registry

    ```bash
    gcloud container builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/ruby-grpc-hello:1.0 .
    ```

1. Either deploy to Google Compute Engine (GCE) below or Google Container Engine
   (GKE) further down.

### Google Compute Engine

1. Create your instance and ssh in.

    ```bash
    gcloud compute instances create grpc-host --image-family gci-stable --image-project google-containers --tags=http-server
    gcloud compute ssh grpc-host
    ```

1. Set some variables to make commands easier

    ```bash
    GOOGLE_CLOUD_PROJECT=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")
    SERVICE_NAME=hellogrpc.endpoints.${GOOGLE_CLOUD_PROJECT}.cloud.goog
    ```

1. Pull your credentials to access Container Registry, and run your
   gRPC server container

    ```bash
    /usr/share/google/dockercfg_update.sh
    docker run -d --name=grpc-hello gcr.io/${GOOGLE_CLOUD_PROJECT}/ruby-grpc-hello:1.0
    ```

1. Run the Endpoints proxy

    ```bash
    docker run --detach --name=esp \
        -p 80:9000 \
        --link=grpc-hello:grpc-hello \
        gcr.io/endpoints-release/endpoints-runtime:1 \
        -s ${SERVICE_NAME} \
        --rollout_strategy managed \
        -P 9000 \
        -a grpc://grpc-hello:50051
    ```

1. Back on your local machine, get the external IP of your GCE instance.

    ```bash
    gcloud compute instances list
    ```

1. Run the client

    ```bash
    bundle exec ruby greeter_client.rb <IP of GCE Instance>:80 <API Key from Console>
    ```

1. Cleanup

    ```bash
    gcloud compute instances delete grpc-host
    ```

### Google Container Engine

1. Create a cluster

    ```bash
    gcloud container clusters create my-cluster
    ```

1. Edit `deployment.yaml`. Replace `SERVICE_NAME` and `GOOGLE_CLOUD_PROJECT` with your values.

1. Deploy to GKE

    ```bash
    kubectl create -f ./deployment.yaml
    ```

1. Get IP of load balancer, run until you see an External IP.

    ```bash
    kubectl get svc grpc-hello
    ```

1. Run the client

    ```bash
    bundle exec ruby greeter_client.rb <IP of GKE LoadBalancer>:80 <API Key from Console>
    ```

1. Cleanup

    ```bash
    gcloud container clusters delete my-cluster
    ```

[1]: https://developers.google.com/protocol-buffers/docs/techniques#self-description
