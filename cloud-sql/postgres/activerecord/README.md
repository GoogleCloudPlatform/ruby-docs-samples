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

To run this application locally, download and install the `cloud_sql_proxy` by
following the instructions
[here](https://cloud.google.com/sql/docs/postgres/authorize-proxy#installing_the).

Instructions are provided below for using the proxy with a TCP connection or a Unix Domain Socket.
On Linux or Mac OS you can use either option, but on Windows the proxy currently requires a TCP
connection.

### Launch proxy with TCP

To run the sample locally with a TCP connection, set environment variables and launch the proxy as
shown below.

#### Linux / Mac OS
Use these terminal commands to initialize environment variables:
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service/account/key.json
export DB_HOST='127.0.0.1'
export DB_PORT='5432'
export DB_USER='<DB_USER_NAME>'
export DB_PASS='<DB_PASSWORD>'
export DB_NAME='<DB_NAME>'
```
Note: Saving credentials in environment variables is convenient, but not secure - consider a more
secure solution such as [Secret Manager](https://cloud.google.com/secret-manager/docs/overview) to
help keep secrets safe.

Then use this command to launch the proxy in the background:
```bash
./cloud_sql_proxy -instances=<project-id>:<region>:<instance-name>=tcp:5432 -credential_file=$GOOGLE_APPLICATION_CREDENTIALS &
```

#### Windows/PowerShell
Use these PowerShell commands to initialize environment variables:
```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="<CREDENTIALS_JSON_FILE>"
$env:DB_HOST="127.0.0.1"
$env:DB_PORT="5432"
$env:DB_USER="<DB_USER_NAME>"
$env:DB_PASS="<DB_PASSWORD>"
$env:DB_NAME="<DB_NAME>"
```
Note: Saving credentials in environment variables is convenient, but not secure - consider a more
secure solution such as [Secret Manager](https://cloud.google.com/secret-manager/docs/overview) to
help keep secrets safe.

Then use this command to launch the proxy in a separate PowerShell session:
```powershell
Start-Process -filepath "C:\<path to proxy exe>" -ArgumentList "-instances=<project-id>:<region>:<instance-name>=tcp:5432 -credential_file=<CREDENTIALS_JSON_FILE>"
```

### Launch proxy with Unix Domain Socket
NOTE: this option is currently only supported on Linux and Mac OS. Windows users should use the
[Launch proxy with TCP](#launch-proxy-with-tcp) option.

To use a Unix socket, you'll need to create a directory and give write access to the user running
the proxy. For example:

```bash
sudo mkdir /cloudsql
sudo chown -R $USER /cloudsql
```

You'll also need to initialize an environment variable containing the directory you just created:
```bash
export DB_SOCKET_DIR=/path/to/the/new/directory
```

Use these terminal commands to initialize other environment variables as well:
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service/account/key.json
export INSTANCE_CONNECTION_NAME='<MY-PROJECT>:<INSTANCE-REGION>:<INSTANCE-NAME>'
export DB_USER='<DB_USER_NAME>'
export DB_PASS='<DB_PASSWORD>'
export DB_NAME='<DB_NAME>'
```
Note: Saving credentials in environment variables is convenient, but not secure - consider a more
secure solution such as [Secret Manager](https://cloud.google.com/secret-manager/docs/overview) to
help keep secrets safe.

Then use this command to launch the proxy in the background:
```bash
./cloud_sql_proxy -dir=$DB_SOCKET_DIR --instances=$INSTANCE_CONNECTION_NAME --credential_file=$GOOGLE_APPLICATION_CREDENTIALS &
```

### Testing the application

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

To allow your app to connect to your Cloud SQL instance when the app is deployed, add the user, password, database, and instance connection name variables from Cloud SQL to the related environment variables in the `app.standard.yaml` file. The deployed application will connect using Unix sockets.

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


## Deploy to Google App Engine Flexible

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
