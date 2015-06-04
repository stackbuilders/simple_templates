require_relative "../test_helper"

require 'set'

describe SimpleTemplates::Parser do
  describe "#placeholder_names" do
    it "should return a set of the placeholder names in the template" do
      SimpleTemplates::Parser.new('foo <bar> <baz>', []).placeholder_names.must_equal ['bar', 'baz'].to_set
    end
  end

  describe "#valid_placeholder_names" do
    it "should return a set of the valid placeholder names in the template" do
      SimpleTemplates::Parser.new('foo <bar> <baz>', ['baz']).valid_placeholder_names.must_equal ['baz'].to_set
    end
  end

  describe "#parse" do
    it "parses a simple valid template" do
      pholder = SimpleTemplates::Parser::Placeholder.new('bar', 4)

      SimpleTemplates::Parser.new('foo <bar>', ['bar']).parse.
        must_equal ['foo ', pholder]
    end

    it "compresses adjacent text nodes after unescaping" do
      pholder = SimpleTemplates::Parser::Placeholder.new('bar', 7)

      SimpleTemplates::Parser.new('foo \< <bar>', ['bar']).parse.
        must_equal ['foo < ', pholder]
    end

    it "returns an error when an opening bracket is found without a closing bracket" do
      SimpleTemplates::Parser.new('foo < <bar>', ['bar']).parse.must_equal [
        SimpleTemplates::Parser::Error.new("Expected placeholder end token at character position 6, but found a placeholder start token instead.")
      ]
    end

    it "returns an error when a closing bracket is found before an opening bracket" do
      SimpleTemplates::Parser.new('foo > <bar>', ['bar']).parse.must_equal [
        SimpleTemplates::Parser::Error.new('Expected placeholder start token at character position 4, but found a placeholder end token instead.')
      ]
    end

    it "returns an error when an invalid placeholder name is found" do
      SimpleTemplates::Parser.new('foo <baz>', ['bar']).parse.must_equal [
        SimpleTemplates::Parser::Error.new("Invalid placeholder with name, 'baz' found starting at position 4.")
      ]
    end

    it "returns an multiple errors when there are multiple invalid placeholders" do
      SimpleTemplates::Parser.new('foo <baz> <buz>', []).parse.must_equal [
        SimpleTemplates::Parser::Error.new("Invalid placeholder with name, 'baz' found starting at position 4."),
        SimpleTemplates::Parser::Error.new("Invalid placeholder with name, 'buz' found starting at position 10.")
      ]
    end

    it "returns an error when multiple opening brackets are found" do
      SimpleTemplates::Parser.new('foo <<baz>', ['bar']).parse.must_equal [
        SimpleTemplates::Parser::Error.new("Expected text token at character position 5, but found a placeholder start token instead.")
      ]
    end

    it "returns an error when empty placeholder is found" do
      SimpleTemplates::Parser.new('foo <>', ['bar']).parse.must_equal [
        SimpleTemplates::Parser::Error.new("Expected text token at character position 5, but found a placeholder end token instead.")
      ]
    end

    it "returns an error when a closing tag is expected, but an opening tag is found" do
      SimpleTemplates::Parser.new('foo <bar<>', ['bar']).parse.must_equal [
        SimpleTemplates::Parser::Error.new("Expected placeholder end token at character position 8, but found a placeholder start token instead.")
      ]
    end

    it "returns an error when a tag is not closed before the end of the input" do
      SimpleTemplates::Parser.new('foo <bar', ['bar']).parse.must_equal [
        SimpleTemplates::Parser::Error.new("Expected placeholder end token, but reached end of input.")
      ]
    end

  end
end
