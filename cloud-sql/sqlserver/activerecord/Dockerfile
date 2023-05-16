# Copyright 2020 Google, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Pull the Google base image for Ruby
# Use the official Ruby image.
# https://hub.docker.com/_/ruby
FROM ruby:3.2-buster

# Install FreeTDS, a dependency of the tiny_tds Ruby connector
RUN apt-get update && apt-get --assume-yes install freetds-dev freetds-bin  

# Set the working directory
WORKDIR /app

# Copy application dependency manifests to the container image.
# Copying this separately prevents re-running bundle install on every code change.
COPY Gemfile Gemfile.lock ./
ENV BUNDLE_FROZEN=true
RUN bundle install

# Copy local code to the container image.
COPY . ./

EXPOSE 8080

# Run the app on container startup.
CMD bundle exec rackup --port 8080 -o 0.0.0.0
