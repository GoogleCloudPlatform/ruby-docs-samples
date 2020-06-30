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



## Running locally

Follow the [instructions on Microsoft's website](https://docs.microsoft.com/en-us/sql/connect/ruby/step-1-configure-development-environment-for-ruby-development?view=sql-server-ver15) for your operating system to make sure your development environment is properly configured. For Unix systems, this will require installing [FreeTDS](https://www.freetds.org/index.html), while Windows systems require [Ruby DevKit](https://rubyinstaller.org/downloads/)

Next, download and install the `cloud_sql_proxy` by
following the instructions
[here](https://cloud.google.com/sql/docs/sqlserver/authorize-proxy#installing_the).

### Linux / MacOS
Use these terminal commands to initialize environment variables:
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service/account/key.json
export CLOUD_SQL_CONNECTION_NAME='<MY-PROJECT>:<INSTANCE-REGION>:<INSTANCE-NAME>'
export DB_USER='my-db-user'
export DB_PASS='my-db-pass'
export DB_NAME='my_db'
export DB_HOST='127.0.0.1'
export DB_PORT='1433'
```
Note: Saving credentials in environment variables is convenient, but not secure - consider a more
secure solution such as [Secret Manager](https://cloud.google.com/secret-manager/docs/overview) to
help keep secrets safe.

Then, use the following command to start the proxy in the background using TCP:
```bash
./cloud_sql_proxy -instances=${CLOUD_SQL_CONNECTION_NAME}=tcp:1433 sqlserver -u ${DB_USER} --host 127.0.0.1 &
```

### Windows / PowerShell
Use these PowerShell commands to initialize environment variables:
```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="<CREDENTIALS_JSON_FILE>"
$env:CLOUD_SQL_CONNECTION_NAME="<MY-PROJECT>:<INSTANCE-REGION>:<INSTANCE-NAME>"
$env:DB_USER="my-db-user"
$env:DB_PASS="my-db-pass"
$env:DB_NAME="my_db"
$env:DB_HOST="127.0.0.1"
$env:DB_PORT="1433"
```
Note: Saving credentials in environment variables is convenient, but not secure - consider a more
secure solution such as [Secret Manager](https://cloud.google.com/secret-manager/docs/overview) to
help keep secrets safe.

Then use this command to launch the proxy in a separate PowerShell session:
```powershell
Start-Process -filepath "C:\<path to proxy exe>" -ArgumentList "-instances=<MY-PROJECT>:<INSTANCE-REGION>:<INSTANCE-NAME>=tcp:1433 -credential_file=<CREDENTIALS_JSON_FILE>"
```

### Testing the application

Next, setup install the requirements:
```bash
bundle install
```

Then, setup and seed the database. You only need to do this once:
```bash
bundle exec rails db:create
bundle exec rails db:migrate
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

Next, create your production database. You only need to do this once:
```bash
RAILS_ENV=production bundle exec rails db:create
RAILS_ENV=production bundle exec rails db:schema:load
```

Finally, the following command will deploy the application to your Google Cloud project:
```bash
gcloud beta app deploy
```
