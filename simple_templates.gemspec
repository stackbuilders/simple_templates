#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require File.expand_path("../lib/simple_templates/version.rb", __FILE__)

Gem::Specification.new do |s|
  s.name = "simple_templates"
  s.version = SimpleTemplates::VERSION
  s.authors = ['Justin Leitgeb', 'Michal Papis']
  s.email = ['support@stackbuilders.com', 'mpapis@gmail.com']
  s.homepage = "https://github.com/stackbuilders/simple_templates"
  s.summary = "Minimalistic templates engine"
  s.license = "MIT"
  s.files = `git ls-files`.split("\n")
  s.executables << "simple-template"
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.required_ruby_version = ">= 2.0.0"
  %w{rake minitest simplecov coveralls guard-minitest yard}.each do |name|
    s.add_development_dependency(name)
  end
  s.add_development_dependency("guard", ">=2.12.8", "<3")
  # s.add_development_dependency("smf-gem")
end
