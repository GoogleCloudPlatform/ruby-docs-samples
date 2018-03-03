#!/bin/bash

source $KOKORO_GFILE_DIR/secrets.sh

sudo apt-get update
sudo apt-get install realpath wget
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64

# Unsure about the following section because of Ruby image
mv cloud_sql_proxy.linux.amd64 $HOME/cloud_sql_proxy
chmod +x $HOME/cloud_sql_proxy
sudo mkdir /cloudsql && sudo chmod 0777 /cloudsql

cd github/ruby-docs-samples/
./spec/kokoro-run-all.sh
