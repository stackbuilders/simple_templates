require "rake/testtask"

task :default => [:test]

begin
  require "yard"
  YARD::Rake::YardocTask.new do |t|
    t.files   = ["lib/**/*.rb"]
    t.stats_options = ["--list-undoc", "--compact"]
  end

  task :docs    => [:yard]
rescue LoadError
end

Rake::TestTask.new do |t|
  t.verbose = true
  t.libs.push("demo", "test")
  t.pattern = "test/**/*_test.rb"
end
