require "sinatra"

get "/" do
# [START logging_example]
  logger.info "Hello World!"
  logger.error "Oh No!"
# [END logging_example]
end
