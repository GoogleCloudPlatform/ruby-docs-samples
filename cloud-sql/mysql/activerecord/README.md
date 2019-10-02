# Connecting to Cloud SQL - MySQL

## Before you begin

1. If you haven't already, set up a Ruby Development Environment by following the [ruby setup guide](https://cloud.google.com/ruby/docs/setup) and 
[create a project](https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project).

1. Create a 2nd Gen Cloud SQL Instance by following these 
[instructions](https://cloud.google.com/sql/docs/mysql/create-instance). Note the connection string,
database user, and database password that you create.

1. Create a database for your application by following these 
[instructions](https://cloud.google.com/sql/docs/mysql/create-manage-databases). Note the database
name. 

1. Create a service account with the 'Cloud SQL Client' permissions by following these 
[instructions](https://cloud.google.com/sql/docs/mysql/connect-external-app#4_if_required_by_your_authentication_method_create_a_service_account).
Download a JSON key to use to authenticate your connection. 

1. Use the information noted in the previous steps:
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service/account/key.json
export INSTANCE_CONNECTION_NAME='<MY-PROJECT>:<INSTANCE-REGION>:<INSTANCE-NAME>'
export MYSQL_USER='my-db-user'
export MYSQL_PASS='my-db-pass'
export MYSQL_DATABASE='my_db'
```
Note: Saving credentials in environment variables is convenient, but not secure - consider a more
secure solution such as [Cloud KMS](https://cloud.google.com/kms/) to help keep secrets safe.

## Running locally

To run this application locally, download and install the `cloud_sql_proxy` by
following the instructions
[here](https://cloud.google.com/sql/docs/mysql/sql-proxy#install). Once the
proxy has been downloaded, use the following commands to create the `/cloudsql`
directory and give the user running the proxy the appropriate permissions:
```bash
sudo mkdir /cloudsql
sudo chown -R $USER /cloudsql
```

Once the `/cloudsql` directory is ready, use the following command to start the proxy in the
background:
```bash
./cloud_sql_proxy -dir=/cloudsql --instances=$INSTANCE_CONNECTION_NAME --credential_file=$GOOGLE_APPLICATION_CREDENTIALS
```
Note: Make sure to run the command under a user with write access in the 
`/cloudsql` directory. This proxy will use this folder to create a unix socket
the application will use to connect to Cloud SQL. 

Next, setup install the requirements:
```bash
bundle install
```

Then, setup and seed the database:
```bash
bundle exec rails db:setup
bundle exec rails db:seed
```

Finally, start the application:
```bash
bundle exec rails s
```

Navigate towards `http://localhost:3000` to verify your application is running correctly.

## Google App Engine Flexible

To run on GAE-Flex, create an App Engine project by following the setup for these 
[instructions](https://cloud.google.com/appengine/docs/flexible/ruby/quickstart).

First, update `app.yaml` with the correct values to pass the environment 
variables into the runtime.

SECRET_KEY_BASE can be found by running:
```bash
bundle exec rails secret
```

Next, the following command will deploy the application to your Google Cloud project:
```bash
gcloud app deploy
```
