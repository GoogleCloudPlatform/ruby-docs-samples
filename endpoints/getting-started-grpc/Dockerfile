# The Google App Engine Ruby runtime is Debian Jessie with Ruby installed
# and various os-level packages to allow installation of popular Ruby
# gems. The source is on github at:
#   https://github.com/GoogleCloudPlatform/ruby-docker
FROM gcr.io/google_appengine/ruby

# Install required gems.
COPY Gemfile Gemfile.lock /app/
RUN bundle install && rbenv rehash

# Copy Server
COPY . /app/

# Reset entrypoint to override base image.
ENTRYPOINT []

CMD ["bundle", "exec", "ruby", "greeter_server.rb"]
