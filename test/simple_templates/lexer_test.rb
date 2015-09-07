require_relative "../test_helper"

describe SimpleTemplates::Lexer do
  describe '#tokenize' do
    it 'tokenizes a string with no placeholders' do
      raw_input = 'string with no placeholders'
      tokens = SimpleTemplates::Lexer.new(
        SimpleTemplates::Delimiter.new(/\\</, /\\>/, /\</, /\>/),
        raw_input
      ).tokenize

      tokens.must_equal [
        SimpleTemplates::Lexer::Token.new(:text, 'string with no placeholders', 0)
      ]
    end

    it 'tokenizes a string with placeholders' do
      raw_input = 'string with <placeholder>'
      tokens = SimpleTemplates::Lexer.new(
        SimpleTemplates::Delimiter.new(/\\</, /\\>/, /\</, /\>/),
        raw_input
      ).tokenize

      tokens.must_equal [
        SimpleTemplates::Lexer::Token.new(:text, 'string with ', 0),
        SimpleTemplates::Lexer::Token.new(:ph_start, '<', 12),
        SimpleTemplates::Lexer::Token.new(:placeholder, 'placeholder', 13),
        SimpleTemplates::Lexer::Token.new(:ph_end, '>', 24)
      ]
    end

    it 'tokenizes a string with invalid placeholders, contains new line character' do
      raw_input = "string with <foo\nbar> text"
      tokens = SimpleTemplates::Lexer.new(
        SimpleTemplates::Delimiter.new(/\\</, /\\>/, /\</, /\>/),
        raw_input
      ).tokenize

      tokens.must_equal [
        SimpleTemplates::Lexer::Token.new(:text, 'string with ', 0),
        SimpleTemplates::Lexer::Token.new(:ph_start, '<', 12),
        SimpleTemplates::Lexer::Token.new(:placeholder, 'foo', 13),
        SimpleTemplates::Lexer::Token.new(:text, "\nbar", 16),
        SimpleTemplates::Lexer::Token.new(:ph_end, '>', 20),
        SimpleTemplates::Lexer::Token.new(:text, ' text', 21)
      ]
    end

    it 'tokenizes a string with invalid placeholders, contains leading and trailing space' do
      raw_input = "string with < foobar > text"
      tokens = SimpleTemplates::Lexer.new(
        SimpleTemplates::Delimiter.new(/\\</, /\\>/, /\</, /\>/),
        raw_input
      ).tokenize

      tokens.must_equal [
        SimpleTemplates::Lexer::Token.new(:text, 'string with ', 0),
        SimpleTemplates::Lexer::Token.new(:ph_start, '<', 12),
        SimpleTemplates::Lexer::Token.new(:text, ' foobar ', 13),
        SimpleTemplates::Lexer::Token.new(:ph_end, '>', 21),
        SimpleTemplates::Lexer::Token.new(:text, ' text', 22)
      ]
    end

    it 'tokenizes a string with placeholders and new line character' do
      raw_input = "string with <placeholder>\n Something else"
      tokens = SimpleTemplates::Lexer.new(
        SimpleTemplates::Delimiter.new(/\\</, /\\>/, /\</, /\>/),
        raw_input
      ).tokenize

      tokens.must_equal [
        SimpleTemplates::Lexer::Token.new(:text, 'string with ', 0),
        SimpleTemplates::Lexer::Token.new(:ph_start, '<', 12),
        SimpleTemplates::Lexer::Token.new(:placeholder, 'placeholder', 13),
        SimpleTemplates::Lexer::Token.new(:ph_end, '>', 24),
        SimpleTemplates::Lexer::Token.new(:text, "\n Something else", 25)
      ]
    end
  end
end
