require "coveralls"
require "simplecov"

require_relative "../lib/simple_templates"

SimpleCov.start do
  formatter SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter,
  ]
  command_name "Unit Tests"
  add_filter "/test/"
end

Coveralls.noisy = true unless ENV["CI"]

gem "minitest"
require "minitest/autorun" unless $0=="-e" # skip in guard
require "minitest/unit"

Dir["lib/**/*.rb"].each{|file|
  file = file.split(/lib\//).last
  require file
}
