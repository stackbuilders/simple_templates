require_relative "../test_helper"

require 'set'

describe SimpleTemplates::Template do
  describe "#placeholder_names" do
    it "should return a set of the placeholder names in the template" do
      SimpleTemplates.parse('foo <bar> <baz>', [:bar, :baz]).
        placeholder_names.must_equal ['bar', 'baz'].to_set
    end
  end

  describe "#render" do
    it "processes an empty template" do
      SimpleTemplates.parse('', []).render(
        {bar: 'baz'}
      ).must_equal ''
    end

    it "interpolates a simple, valid template" do
      SimpleTemplates.parse('foo <bar>', [:bar]).render(
        {bar: 'baz'}
      ).must_equal 'foo baz'
    end

    it "interpolates a template containing an escaped '>'" do
      SimpleTemplates.parse("foo <bar> \\>", [:bar]).render(
        {bar: 'baz'}
      ).must_equal "foo baz \>"
    end

    it "interpolates a template containing an escaped '<'" do
      SimpleTemplates.parse("foo <bar> \\<", [:bar]).render(
        {bar: 'baz'}
      ).must_equal "foo baz \<"
    end

    it "interpolates a template containing an escaped escape character" do
      SimpleTemplates.parse("foo <bar> \\", [:bar]).render(
        {bar: 'baz'}
      ).must_equal "foo baz \\"
    end
  end

  describe '#to_json' do
    it 'serializes a template to a JSON string' do
      template_as_json = %(
        {
           "ast":[
              {
                 "contents":"Hi ",
                 "pos":0,
                 "allowed":true,
                 "class":"SimpleTemplates::AST::Text"
              },
              {
                 "contents":"name",
                 "pos":3,
                 "allowed":false,
                 "class":"SimpleTemplates::AST::Placeholder"
              }
           ],
           "errors":[
              {
                 "message":"Invalid Placeholder with contents, 'name' found starting at position 3."
              }
           ],
           "remaining_tokens":[]
        }
      )

      template = SimpleTemplates.parse('Hi <name>', %w[date])
      JSON.parse(template.to_json).must_equal(JSON.parse(template_as_json))
    end
  end

  describe "#==" do
    it "compares the ast" do
      SimpleTemplates::Template.new([:ast_a], [], []).wont_equal SimpleTemplates::Template.new([:ast_b], [], [])
    end

    it "compares the errors" do
      SimpleTemplates::Template.new([], [:error_a], []).wont_equal SimpleTemplates::Template.new([], [:error_b], [])
    end

    it "compares the remaining tokens" do
      SimpleTemplates::Template.new([], [], [:remaining_tokens_a]).wont_equal SimpleTemplates::Template.new([], [], [:remaining_tokens_b])
    end
  end
end
