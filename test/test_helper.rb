gem "minitest"
require "minitest/autorun" unless $0=="-e" # skip in guard
require "minitest/unit"

Dir["lib/**/*.rb"].each{|file|
  file = file.split(/lib\//).last
  require file
}
