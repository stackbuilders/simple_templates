require_relative "../test_helper"

require 'set'

describe SimpleTemplates::Parser do
  describe "#parse" do
    it "parses a simple valid template" do
      pholder = SimpleTemplates::AST::Placeholder.new('bar', 4)

      SimpleTemplates.parse('foo <bar>', ['bar']).
        must_equal SimpleTemplates::ParseResult.new(
          SimpleTemplates::Template.new([SimpleTemplates::AST::Text.new('foo ', 0), pholder]),
          [])
    end

    it "compresses adjacent text nodes after unescaping" do
      pholder = SimpleTemplates::AST::Placeholder.new('bar', 7)

      SimpleTemplates.parse('foo \< <bar>', ['bar']).template.
        must_equal SimpleTemplates::Template.new([SimpleTemplates::AST::Text.new('foo < ', 0), pholder])
    end

    it "returns an error when an opening bracket is found without a closing bracket" do
      SimpleTemplates.parse('foo < <bar>', ['bar']).must_equal SimpleTemplates::ParseResult.new(nil, [
        SimpleTemplates::Parser::Error.new("Expected placeholder end token at character position 6, but found a placeholder start token instead.")
      ])
    end

    it "returns an error when a closing bracket is found before an opening bracket" do
      SimpleTemplates.parse('foo > <bar>', ['bar']).must_equal SimpleTemplates::ParseResult.new(nil, [
        SimpleTemplates::Parser::Error.new('Expected placeholder start token at character position 4, but found a placeholder end token instead.')
      ])
    end

    it "returns errors about invalid placeholders encountered before a syntactical error" do
      SimpleTemplates.parse('foo <baz> >', []).must_equal SimpleTemplates::ParseResult.new(nil, [
        SimpleTemplates::Parser::Error.new('Expected placeholder start token at character position 10, but found a placeholder end token instead.'),
        SimpleTemplates::Parser::Error.new('Invalid placeholder with name, \'baz\' found starting at position 4.')
      ])
    end

    it "returns an error when an invalid placeholder name is found" do
      SimpleTemplates.parse('foo <baz>', ['bar']).must_equal SimpleTemplates::ParseResult.new(nil, [
        SimpleTemplates::Parser::Error.new("Invalid placeholder with name, 'baz' found starting at position 4.")
      ])
    end

    it "returns an multiple errors when there are multiple invalid placeholders" do
      SimpleTemplates.parse('foo <baz> <buz>', []).must_equal SimpleTemplates::ParseResult.new(nil, [
        SimpleTemplates::Parser::Error.new("Invalid placeholder with name, 'baz' found starting at position 4."),
        SimpleTemplates::Parser::Error.new("Invalid placeholder with name, 'buz' found starting at position 10.")
      ])
    end

    it "returns an error when multiple opening brackets are found" do
      SimpleTemplates.parse('foo <<baz>', ['bar']).must_equal SimpleTemplates::ParseResult.new(nil, [
        SimpleTemplates::Parser::Error.new("Expected text token at character position 5, but found a placeholder start token instead.")
      ])
    end

    it "returns an error when empty placeholder is found" do
      SimpleTemplates.parse('foo <>', ['bar']).must_equal SimpleTemplates::ParseResult.new(nil, [
        SimpleTemplates::Parser::Error.new("Expected text token at character position 5, but found a placeholder end token instead.")
      ])
    end

    it "returns an error when a closing tag is expected, but an opening tag is found" do
      SimpleTemplates.parse('foo <bar<>', ['bar']).must_equal SimpleTemplates::ParseResult.new(nil, [
        SimpleTemplates::Parser::Error.new("Expected placeholder end token at character position 8, but found a placeholder start token instead.")
      ])
    end

    it "returns an error when a tag is not closed before the end of the input" do
      SimpleTemplates.parse('foo <bar', ['bar']).must_equal SimpleTemplates::ParseResult.new(nil, [
        SimpleTemplates::Parser::Error.new("Expected placeholder end token, but reached end of input.")
      ])
    end
  end
end
