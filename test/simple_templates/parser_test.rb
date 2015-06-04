require_relative "../test_helper"
require_relative "../../lib/simple_templates"

require 'ostruct'

describe SimpleTemplates::Parser do
  describe "#parse" do
    it "parses a simple valid template" do
      pholder = SimpleTemplates::Parser::Placeholder.new('bar')

      SimpleTemplates::Parser.new('foo <bar>', ['bar']).parse.
        must_equal ['foo ', pholder]
    end

    it "compresses adjacent text nodes after unescaping" do
      pholder = SimpleTemplates::Parser::Placeholder.new('bar')

      SimpleTemplates::Parser.new('foo \< <bar>', ['bar']).parse.
        must_equal ['foo < ', pholder]
    end

    it "returns an error when an opening bracket is found without a closing bracket" do
      SimpleTemplates::Parser.new('foo < <bar>', ['bar']).parse.must_equal [
        SimpleTemplates::Parser::Error.new("Invalid placeholder name ' ' found at position 5.")
      ]
    end

    it "returns an error when a closing bracket is found before an opening bracket" do
      SimpleTemplates::Parser.new('foo > <bar>', ['bar']).parse.must_equal [
        SimpleTemplates::Parser::Error.new('Unexpected closing bracket found at position 4.')
      ]
    end

    it "returns an error when an invalid placeholder name is found" do
      SimpleTemplates::Parser.new('foo <baz>', ['bar']).parse.must_equal [
        SimpleTemplates::Parser::Error.new("Invalid placeholder name 'baz' found at position 5.")
      ]
    end

    it "returns an error when multiple opening brackets are found" do
      SimpleTemplates::Parser.new('foo <<baz>', ['bar']).parse.must_equal [
        SimpleTemplates::Parser::Error.new("Expected to find a valid placeholder name at 5, but found a ph_start instead.")
      ]
    end

    it "returns an error when a closing tag is expected, but an opening tag is found" do
      SimpleTemplates::Parser.new('foo <bar<>', ['bar']).parse.must_equal [
        SimpleTemplates::Parser::Error.new("Expected closing tag for placeholder which started at position 4, but found a ph_start instead.")
      ]
    end

    it "returns an error when a tag is not closed before the end of the input" do
      SimpleTemplates::Parser.new('foo <bar', ['bar']).parse.must_equal [
        SimpleTemplates::Parser::Error.new("No closing tag found for placeholder which started at position 4.")
      ]
    end

  end
end
