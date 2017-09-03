# Stackdriver Samples

Samples used by Stackdriver documentation. The samples don't work out-of-the-box
and require some modification. The samples are provided as reference guides
when using Rails, Sinatra, other-rack frameworks, and non-rack apps.

## Rails

The `rails_configuration.rb` provides a configuration example that can be used
in your `config/environments/*.rb` files.

## Sinatra

Sinatra exmple apps load middleware using a rack configuration file. For example
`rackup rack_debugger.ru` is an example of starting a Sinatra app with
Stackdriver Debugger.

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

### Shared Configuration

Stackdriver gems can be configured using shared configuration which is shown in
`shared_config.ru`

## Non-rack apps

An additional example shows that Debugger doesn't require a Rack
based app.

- `non_rack_debugger.rb`
