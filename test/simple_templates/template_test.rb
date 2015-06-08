require_relative "../test_helper"

require 'set'

describe SimpleTemplates::Template do
  describe "#placeholder_names" do
    it "should return a set of the placeholder names in the template" do
      SimpleTemplates.parse('foo <bar> <baz>', ['bar', 'baz']).
        template.placeholder_names.must_equal ['bar', 'baz'].to_set
    end
  end

  describe "#render" do
    it "processes an empty template" do
      SimpleTemplates.parse('', []).template.render(
        OpenStruct.new(bar: 'baz')
      ).must_equal ''
    end

    it "interpolates a simple, valid template" do
      SimpleTemplates.parse('foo <bar>', ['bar']).template.render(
        OpenStruct.new(bar: 'baz')
      ).must_equal 'foo baz'
    end

    it "interpolates a template containing an escaped '>'" do
      SimpleTemplates.parse("foo <bar> \\>", ['bar']).template.render(
        OpenStruct.new(bar: 'baz')
      ).must_equal "foo baz \>"
    end

    it "interpolates a template containing an escaped '<'" do
      SimpleTemplates.parse("foo <bar> \\<", ['bar']).template.render(
        OpenStruct.new(bar: 'baz'),
      ).must_equal "foo baz \<"
    end

    it "interpolates a template containing an escaped escape character" do
      SimpleTemplates.parse("foo <bar> \\", ['bar']).template.render(
        OpenStruct.new(bar: 'baz')
      ).must_equal "foo baz \\"
    end
  end
end
