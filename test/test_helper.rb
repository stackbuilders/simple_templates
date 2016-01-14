require "coveralls"
require "simplecov"

SimpleCov.start do
  formatters = [ SimpleCov::Formatter::HTMLFormatter,
                 Coveralls::SimpleCov::Formatter ]
  formatter SimpleCov::Formatter::MultiFormatter.new(formatters)
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
