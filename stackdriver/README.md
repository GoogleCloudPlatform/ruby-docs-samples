# Stackdriver Samples

Samples used by Stackdriver documentation. The samples are provided as reference
guides when using Rails, Sinatra, other-rack frameworks, and pure Ruby.

## Rails

The `rails_configuration.rb` provides configuration examples that can be used
in your `config/environments/*.rb` files.

## Rack and Sinatra

Sinatra samples are prefixed with `sinatra_` and Rack examples use the extension
`.ru`.

The following list provides samples used per Stackdriver product.

### Debugger

- `debugger.ru`
- `sinatra_debugger.rb`

### Trace

- `trace.ru`
- `sinatra_trace.rb`

### Logging

- `logging.ru`
- `sinatra_logging.rb`

### Error Reporting

- `error_reporting.ru`
- `sinatra_error_reporting.rb`

### Uptime Checks

- `uptime_check.rb`


### Shared Configuration

The following file shows an example of using shared configuration in a Rack app,
and can also be used in Sinatra or pure Ruby apps.

- `shared_config.ru`

## Pure Ruby apps

An additional example shows that Debugger doesn't require a Rack based app.

- `ruby_debugger.rb`
