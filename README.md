## Ruby docs samples [![Build Status](https://travis-ci.org/GoogleCloudPlatform/ruby-docs-samples.svg?branch=master)](https://travis-ci.org/GoogleCloudPlatform/ruby-docs-samples)

Kokoro: [![Kokoro](https://storage.googleapis.com/cloud-devrel-kokoro-resources/ruby/ruby-docs-samples/system_tests-ubuntu.png)](https://fusion.corp.google.com/projectanalysis/current/KOKORO/prod:cloud-devrel%2Fruby%2Fruby-docs-samples%2Fsystem_tests)

This repository holds samples used in the ruby documentation on
cloud.google.com.

See our other [Google Cloud Platform github
repos](https://github.com/GoogleCloudPlatform) for sample applications and
scaffolding for other frameworks and use cases.

## Run Locally
1. Clone this repo.
   ```
   git clone https://github.com/GoogleCloudPlatform/ruby-docs-samples.git
   ```

1. Change directories to the sample that you want to test. Example:
   ```
   cd ruby-docs-samples/storage
   ```

1. Run the tests from the command line.
   ```
   bundle install
   bundle exec rspec
   ```

## Contributing changes

Contributions to this sample repository are always welcome and highly encouraged.

See [CONTRIBUTING](CONTRIBUTING.md) for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms. See [Code of Conduct](CODE_OF_CONDUCT.md) for more information.

## Licensing

* See [LICENSE](LICENSE)
