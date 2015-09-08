require_relative "../test_helper"

require 'set'

describe SimpleTemplates::Parser do
  describe "#parse" do
    it "parses a simple valid template" do
      pholder = SimpleTemplates::AST::Placeholder.new('bar', 4, true)

      SimpleTemplates.parse('foo <bar>', ['bar']).must_equal SimpleTemplates::Template.new(
        [SimpleTemplates::AST::Text.new('foo ', 0, true), pholder],
        [],
        []
      )
    end

    it "compresses adjacent text nodes after unescaping" do
      pholder = SimpleTemplates::AST::Placeholder.new('bar', 7, true)

      SimpleTemplates.parse('foo \< <bar>', ['bar']).ast.must_equal [
        SimpleTemplates::AST::Text.new('foo < ', 0, true), pholder
      ]
    end

    it "allows text after placeholders" do
      pholder  = SimpleTemplates::AST::Placeholder.new('bar', 7, true)
      pholder2 = SimpleTemplates::AST::Placeholder.new('baz', 13, true)

      SimpleTemplates.parse('foo \< <bar> <baz>', ['bar', 'baz']).must_equal SimpleTemplates::Template.new(
        [
          SimpleTemplates::AST::Text.new('foo < ', 0, true),
          pholder,
          SimpleTemplates::AST::Text.new(' ', 12, true),
          pholder2
        ],
        [],
        []
      )
    end

    it "allows templates starting with placeholders" do
      pholder = SimpleTemplates::AST::Placeholder.new('foo', 0, true)

      SimpleTemplates.parse('<foo> bar', ['foo']).ast.must_equal [
        pholder,
        SimpleTemplates::AST::Text.new(' bar', 5, true)
      ]
    end

    it "allows templates with placeholders that contain underscores" do
      pholder = SimpleTemplates::AST::Placeholder.new('some_name', 0, true)

      SimpleTemplates.parse('<some_name> bar', ['some_name']).ast.must_equal [
        pholder,
        SimpleTemplates::AST::Text.new(' bar', 11, true)
      ]
    end

    it "parses other placeholder types by changing the delimiter Struct" do
      pholder = SimpleTemplates::AST::Placeholder.new('foo', 0, true)

      delim = SimpleTemplates::Delimiter.new(/\\\[\\\[/, /\\\]\\\]/, /\[\[/, /\]\]/)

      ast, errors, remaining_tokens =
      SimpleTemplates::Template.new(
        *SimpleTemplates::Parser.new(
          SimpleTemplates::Unescapes.new('[[', ']]'),
          SimpleTemplates::Lexer.new(delim, '[[foo]] \[\[ bar').tokenize,
          ['foo']
        ).parse
      )

      ast.ast.must_equal [
        pholder,
        SimpleTemplates::AST::Text.new(' [[ bar', 7, true)
      ]
    end

    it "returns an error when an opening bracket is found without a closing bracket" do
      SimpleTemplates.parse('foo < <bar>', ['bar']).errors.must_equal [
        SimpleTemplates::Parser::Error.new("Expected placeholder name token at character position 5, but found a text token instead.")
      ]
    end

    it "returns an error when a closing bracket is found before an opening bracket" do
      SimpleTemplates.parse('foo > <bar>', ['bar']).errors.must_equal [
        SimpleTemplates::Parser::Error.new('Encountered unexpected token in stream (placeholder end), but expected to see one of the following types: placeholder start, quoted placeholder start, quoted placeholder end, text.')
      ]
    end

    it "returns errors about invalid placeholders encountered before a syntactical error" do
      SimpleTemplates.parse('foo <baz> >', []).errors.must_equal [
        SimpleTemplates::Parser::Error.new('Encountered unexpected token in stream (placeholder end), but expected to see one of the following types: placeholder start, quoted placeholder start, quoted placeholder end, text.'),
        SimpleTemplates::Parser::Error.new('Invalid SimpleTemplates::AST::Placeholder with contents, \'baz\' found starting at position 4.')
      ]
    end

    it "returns an error when an invalid placeholder name is found" do
      SimpleTemplates.parse('foo <baz>', ['bar']).errors.must_equal [
        SimpleTemplates::Parser::Error.new("Invalid SimpleTemplates::AST::Placeholder with contents, 'baz' found starting at position 4.")]
    end

    it "returns an error when a placeholder with newlines is found" do
      SimpleTemplates.parse("foo <ba\nr>", ["ba\nr"]).errors.must_equal [
        SimpleTemplates::Parser::Error.new("Expected placeholder end token at character position 7, but found a text token instead.")]
    end

    it "returns an error when a placeholder with spaces is found" do
      SimpleTemplates.parse("foo <ba r>", ['ba r']).errors.must_equal [
        SimpleTemplates::Parser::Error.
        new("Expected placeholder end token at character position 7, but found a text token instead.")]
    end

    it "returns an error when a placeholder with tabs is found" do
      SimpleTemplates.parse("foo <ba\tr>", ["ba\tr"]).errors.must_equal [
        SimpleTemplates::Parser::Error.new("Expected placeholder end token at character position 7, but found a text token instead.")]
    end

    it "returns an error when a placeholder with other characters is found" do
      SimpleTemplates.parse("foo <ba-r>", ['ba-r']).errors.must_equal [
        SimpleTemplates::Parser::Error.new("Expected placeholder end token at character position 7, but found a text token instead.")]
    end


    it "returns an multiple errors when there are multiple invalid placeholders" do
      SimpleTemplates.parse('foo <baz> <buz>', []).errors.must_equal [
        SimpleTemplates::Parser::Error.new("Invalid SimpleTemplates::AST::Placeholder with contents, 'baz' found starting at position 4."),
        SimpleTemplates::Parser::Error.new("Invalid SimpleTemplates::AST::Placeholder with contents, 'buz' found starting at position 10.")
      ]
    end

    it "returns an error when multiple opening brackets are found" do
      SimpleTemplates.parse('foo <<baz>', ['bar']).errors.must_equal [
        SimpleTemplates::Parser::Error.new("Expected placeholder name token at character position 5, but found a placeholder start token instead.")]
    end

    it "returns an error when empty placeholder is found" do
      SimpleTemplates.parse('foo <>', ['bar']).errors.must_equal [
        SimpleTemplates::Parser::Error.new("Expected placeholder name token at character position 5, but found a placeholder end token instead.")]
    end

    it "returns an error when a closing tag is expected, but an opening tag is found" do
      SimpleTemplates.parse('foo <bar<>', ['bar']).errors.must_equal [
        SimpleTemplates::Parser::Error.new("Expected placeholder end token at character position 8, but found a placeholder start token instead.")
      ]
    end

    it "returns an error when a tag is not closed before the end of the input" do
      SimpleTemplates.parse('foo <bar', ['bar']).errors.must_equal [
        SimpleTemplates::Parser::Error.new("Expected placeholder end token, but reached end of input.")
      ]
    end
  end
end
