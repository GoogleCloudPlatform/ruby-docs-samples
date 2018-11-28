<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google
Cloud Platform logo" title="Google Cloud Platform" align="right" height="96"
width="96"/>

# Google Cloud IoT Core API Samples

## Description

These samples show how to use the [Google Cloud IoT Core API](https://cloud.google.com/iot-core/).

## Build and Run
1.  **Enable APIs** - [Enable the Cloud IoT Core API](https://console.cloud.google.com/flows/enableapi?apiid=cloudiot.googleapis.com)
    and create a new project or select an existing project.
1.  **Install and Initialize Cloud SDK**
    Follow instructions from the available [quickstarts](https://cloud.google.com/sdk/docs/quickstarts)
1.  **Clone the repo** and cd into this directory

```
    $ git clone https://github.com/GoogleCloudPlatform/ruby-docs-samples
    $ cd ruby-docs-samples/iot
```

1. **Install Dependencies** via [Bundler](https://bundler.io).

```
    $ bundle install
```

1. **Set Environment Variables**

```
    $ export GOOGLE_CLOUD_PROJECT="YOUR_PROJECT_ID"
```

1. Use the `generate_keys.sh` script to generate your signing keys:
```
    ./generate_keys.sh
```

1. **Run samples**

```
Usage: bundle exec ruby iot.rb [command] [arguments]

Registry Management Commands:
  create_registry <location> <registry_id> <pubsub_topic> Create a device registry.
  delete_registry <location> <registry_id> Delete a device registry.
  get_registry <location> <registry_id> Get the provided device registry.
  get_iam_policy <location> <registry_id> Get the IAM policy for a registry.
  list_registries <location> List the device registries in the provided region.
  set_iam_policy <location> <registry_id> <member> <role> Set the IAM policy for a registry to a single member / role.

Device Management Commands:
  create_es_device <location> <registry_id> <device_id> <public_key_path> Create a device with an ES256 credential
  create_rsa_device <location> <registry_id> <device_id> <public_key_path> Create a device with an RSA credential
  create_unauth_device <location> <registry_id> <device_id> Create a device without credentials
  delete_device <location> <registry_id> <device_id> Delete a device from a registry
  get_device <location> <registry_id> <device_id> Gets a device from a registry.
  get_device_configs <location> <registry_id> <device_id> List device configurations.
  list_devices <location> <registry_id> List the devices in the provided registry.
  patch_es_device <location> <registry_id> <device_id> <public_key_path> Patch a device with an ES256 credential
  patch_rsa_device <location> <registry_id> <device_id> <public_key_path> Patch a device with an RSA credential
  send_command <location> <registry_id> <device_id> <data> Send a command to a device.
  send_configuration <location> <registry_id> <device_id> <data> Set a device configuration.

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
  GOOGLE_APPLICATION_CREDENTIALS set to the path to your JSON credentials
```

## Contributing changes

* See [CONTRIBUTING.md](../CONTRIBUTING.md)

## Licensing

* See [LICENSE](../LICENSE)

