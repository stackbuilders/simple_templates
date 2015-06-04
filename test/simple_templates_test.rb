require_relative "test_helper"
require_relative "../lib/simple_templates"

require 'ostruct'

describe SimpleTemplates do
  describe "#render" do

    it "processes an empty template" do
      SimpleTemplates.render(
        '',
        OpenStruct.new(bar: 'baz'),
        ['bar']
      ).must_equal ''
    end

    it "interpolates a simple, valid template" do
      SimpleTemplates.render(
        'foo <bar>',
        OpenStruct.new(bar: 'baz'),
        ['bar']
      ).must_equal 'foo baz'
    end

    it "interpolates a template containing an escaped '>'" do
      SimpleTemplates.render(
        "foo <bar> \\>",
        OpenStruct.new(bar: 'baz'),
        ['bar']
      ).must_equal "foo baz \>"
    end

    it "interpolates a template containing an escaped '<'" do
      SimpleTemplates.render(
        "foo <bar> \\<",
        OpenStruct.new(bar: 'baz'),
        ['bar']
      ).must_equal "foo baz \<"
    end

    it "interpolates a template containing an escaped escape character" do
      SimpleTemplates.render(
        "foo <bar> \\",
        OpenStruct.new(bar: 'baz'),
        ['bar']
      ).must_equal "foo baz \\"
    end

    it "raises an error when the template is invalid" do
      lambda {
        SimpleTemplates.render(
          "foo < <bar>",
          OpenStruct.new(bar: 'baz'),
          ['bar']
        ).must_equal "foo baz \<"
      }.must_raise RuntimeError
    end
  end
end
