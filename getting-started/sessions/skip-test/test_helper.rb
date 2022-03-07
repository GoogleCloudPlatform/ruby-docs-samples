ENV["RACK_ENV"] = "test"
require "minitest/autorun"
require "rack/test"

require File.expand_path "../app.rb", __dir__
