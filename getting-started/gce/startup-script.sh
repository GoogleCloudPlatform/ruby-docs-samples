# Copyright 2019 Google LLC All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START getting_started_gce_startup_script]
# Install Stackdriver logging agent
curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
bash add-logging-agent-repo.sh --also-install

# Install dependencies
apt-get update && apt-get -y upgrade && apt-get install -y autoconf bison \
    build-essential git libssl-dev libyaml-dev libreadline6-dev zlib1g-dev \
    libncurses5-dev libffi-dev libgdbm3 libgdbm-dev nginx supervisor

# Account to own server process
useradd -m -d /home/rubyapp rubyapp

# Install Ruby and Bundler
mkdir /home/rubyapp/.ruby
git clone https://github.com/rbenv/ruby-build.git /home/rubyapp/.ruby-build
/home/rubyapp/.ruby-build/bin/ruby-build 2.6.5 /home/rubyapp/.ruby

chown -R rubyapp:rubyapp /home/rubyapp

cat >/home/rubyapp/.profile << EOF
export PATH="/home/rubyapp/.ruby/bin:$PATH"
EOF

su -l rubyapp -c "gem install bundler"

# Fetch source code
git clone https://github.com/GoogleCloudPlatform/getting-started-ruby.git /opt/app

# Set ownership to newly created account
chown -R rubyapp:rubyapp /opt/app

# Install ruby dependencies
su -l rubyapp -c "cd /opt/app/gce && bundle install"

# Disable the default NGINX configuration
rm /etc/nginx/sites-enabled/default

# Enable our NGINX configuration
cp /opt/app/gce/rubyapp.conf /etc/nginx/sites-available/rubyapp.conf
ln -s /etc/nginx/sites-available/rubyapp.conf /etc/nginx/sites-enabled/rubyapp.conf

# Start NGINX
systemctl restart nginx.service

# Configure supervisor to run the ruby app
cat >/etc/supervisor/conf.d/rubyapp.conf << EOF
[program:rubyapp]
directory=/opt/app/gce
command=bash -lc "bundle exec ruby app.rb"
autostart=true
autorestart=true
user=rubyapp
environment=HOME="/home/rubyapp",USER="rubyapp"
stdout_logfile=syslog
stderr_logfile=syslog
EOF

supervisorctl reread
supervisorctl update

# Application should now be running under supervisor
# [END getting_started_gce_startup_script]
