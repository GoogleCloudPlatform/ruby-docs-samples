<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google
Cloud Platform logo" title="Google Cloud Platform" align="right" height="96"
width="96"/>

# Google Cloud Key Management Service API Samples

Cloud KMS allows you to keep encryption keys in one central cloud service, for
direct use by other cloud resources and applications. With Cloud KMS you are the
ultimate custodian of your data, you can manage encryption in the cloud the same
way you do on-premises, and you have a provable and monitorable root of trust
over your data.

## Description

These samples show how to use the [Google Cloud KMS API]
(https://cloud.google.com/kms/).

## Build and Run
1.  **Enable APIs** - [Enable the KMS API](https://console.cloud.google.com/flows/enableapi?apiid=cloudkms.googleapis.com)
    and create a new project or select an existing project.
1.  **Install and Initialize Cloud SDK**
    Follow instructions from the available [quickstarts](https://cloud.google.com/sdk/docs/quickstarts)
1.  **Clone the repo** and cd into this directory

```
    $ git clone https://github.com/GoogleCloudPlatform/ruby-docs-samples
    $ cd ruby-docs-samples/kms
```

1. **Install Dependencies** via [Bundler](https://bundler.io).

```
    $ bundle install
```

1. **Set Environment Variables**

```
    $ export GOOGLE_CLOUD_PROJECT="YOUR_PROJECT_ID"
```

1. **Run samples**

```
Usage: bundle exec ruby kms.rb [command] [arguments]

Commands:
  create_keyring            <key_ring> <location> Create a new keyring
  create_cryptokey          <key_ring> <crypto_key> <location> Create a new cryptokey
  encrypt_file              <key_ring> <crypto_key> <location> <input_file> <output_file> Encrypt a file
  decrypt_file              <key_ring> <crypto_key> <location> <input_file> <output_file> Decrypt a file
  create_cryptokey_version  <key_ring> <crypto_key> <location> Create a new cryptokey version
  enable_cryptokey_version  <key_ring> <crypto_key> <version> <location> Enable a cryptokey version
  disable_cryptokey_version <key_ring> <crypto_key> <version> <location> Disable a cryptokey version
  restore_cryptokey_version <key_ring> <crypto_key> <version> <location> Restore a cryptokey version
  destroy_cryptokey_version <key_ring> <crypto_key> <version> <location> Destroy a cryptokey version
  add_member_to_policy      <key_ring> <crypto_key> <member> <role> <location> Add member to cryptokey IAM policy
  get_keyring_policy        <key_ring> <location> Get a keyring IAM policy

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
```

## Contributing changes

* See [CONTRIBUTING.md](../CONTRIBUTING.md)

## Licensing

* See [LICENSE](../LICENSE)

