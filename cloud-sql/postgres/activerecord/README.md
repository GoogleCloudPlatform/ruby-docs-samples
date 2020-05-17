# Connecting to Cloud SQL - PostgreSQL

## Before you begin

1. If you haven't already, set up a Ruby Development Environment by following the [ruby setup guide](https://cloud.google.com/ruby/docs/setup) and 
[create a project](https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project).

1. Create a 2nd Gen Cloud SQL Instance by following these 
[instructions](https://cloud.google.com/sql/docs/postgres/create-instance). Note the connection string,
database user, and database password that you create.

1. Create a database for your application by following these 
[instructions](https://cloud.google.com/sql/docs/postgres/create-manage-databases). Note the database
name. 

1. Create a service account with the 'Cloud SQL Client' permissions by following these 
[instructions](https://cloud.google.com/sql/docs/postgres/connect-external-app#4_if_required_by_your_authentication_method_create_a_service_account).
Download a JSON key to use to authenticate your connection. 



## Running locally

Use the information noted in the previous steps:
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service/account/key.json
export INSTANCE_CONNECTION_NAME='<MY-PROJECT>:<INSTANCE-REGION>:<INSTANCE-NAME>'
export DB_USER='my-db-user'
export DB_PASS='my-db-pass'
export DB_NAME='my_db'
```
Note: Saving credentials in environment variables is convenient, but not secure - consider a more
secure solution such as [Secret Manager](https://cloud.google.com/secret-manager/docs/overview) to help keep secrets safe.

Then, download and install the `cloud_sql_proxy` by
following the instructions
[here](https://cloud.google.com/sql/docs/postgres/authorize-proxy#installing_the). Once the
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

## Deploy to Google App Engine Standard

To allow your app to connect to your Cloud SQL instance when the app is deployed, add the user, password, database, and instance connection name variables from Cloud SQL to the related environment variables in the `app.standard.yaml` file. The deployed application will connect via unix sockets.

    ```
    env_variables:
      DB_USER: MY_DB_USER
      DB_PASS: MY_DB_PASSWORD
      DB_NAME: MY_DATABASE
      # e.g. my-awesome-project:us-central1:my-cloud-sql-instance
      CLOUD_SQL_CONNECTION_NAME: <MY-PROJECT>:<INSTANCE-REGION>:<MY-DATABASE>
    ```

SECRET_KEY_BASE can be found by running:
```bash
bundle exec rails secret
```

To deploy to App Engine Standard, run the following command:
```bash
gcloud app deploy app.standard.yaml
```


## Google App Engine Flexible

To run on GAE-Flex, create an App Engine project by following the setup for these 
[instructions](https://cloud.google.com/appengine/docs/flexible/ruby/quickstart).

First, update `app.flexible.yaml` with the correct values to pass the environment 
variables into the runtime.

SECRET_KEY_BASE can be found by running:
```bash
bundle exec rails secret
```

To deploy to App Engine Flexible, run the following command:
```bash
gcloud app deploy app.flexible.yaml
```
