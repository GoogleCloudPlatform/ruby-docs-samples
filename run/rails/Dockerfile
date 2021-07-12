# Use the official Ruby image from Docker Hub
# https://hub.docker.com/_/ruby
FROM ruby:3.0

RUN (curl -sL https://deb.nodesource.com/setup_14.x | bash -) && apt-get update && apt-get install -y nodejs 

RUN (curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -) && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

WORKDIR /app

# Application dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install --deployment --without="development test"

# Copy application code to the container image
COPY . /app

ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
# Redirect Rails log to STDOUT for Cloud Run to capture
ENV RAILS_LOG_TO_STDOUT=true
ARG MASTER_KEY
ENV RAILS_MASTER_KEY=${MASTER_KEY}

# pre-compile Rails assets with master key
RUN bundle exec rake assets:precompile

EXPOSE 8080
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "8080"]
