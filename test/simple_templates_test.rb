require_relative "test_helper"

require 'ostruct'

describe SimpleTemplates do
  describe "#render" do

    it "processes an empty template" do
      SimpleTemplates.render(
        SimpleTemplates.parse('', []).template,
        OpenStruct.new(bar: 'baz')
      ).must_equal ''
    end

    it "interpolates a simple, valid template" do
      SimpleTemplates.render(
        SimpleTemplates.parse('foo <bar>', ['bar']).template,
        OpenStruct.new(bar: 'baz')
      ).must_equal 'foo baz'
    end

    it "interpolates a template containing an escaped '>'" do
      SimpleTemplates.render(
        SimpleTemplates.parse("foo <bar> \\>", ['bar']).template,
        OpenStruct.new(bar: 'baz')
      ).must_equal "foo baz \>"
    end

    it "interpolates a template containing an escaped '<'" do
      SimpleTemplates.render(
        SimpleTemplates.parse("foo <bar> \\<", ['bar']).template,
        OpenStruct.new(bar: 'baz'),
      ).must_equal "foo baz \<"
    end

    it "interpolates a template containing an escaped escape character" do
      SimpleTemplates.render(
        SimpleTemplates.parse("foo <bar> \\", ['bar']).template,
        OpenStruct.new(bar: 'baz')
      ).must_equal "foo baz \\"
    end

    it "raises an error when an attempt is made to render with an invalid template" do
      lambda {
        SimpleTemplates.render(SimpleTemplates::Parser::Result.new(nil, []))
      }.must_raise ArgumentError
    end
  end
end
