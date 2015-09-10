require_relative "../test_helper"

describe SimpleTemplates::Lexer do
  let(:delimiter) { SimpleTemplates::Delimiter.new(/\\</, /\\>/, /\</, /\>/) }
  let(:token) { SimpleTemplates::Lexer::Token }

  describe '#tokenize' do
    it 'tokenizes a string with no placeholders' do
      raw_input = 'string with no placeholders'
      tokens = SimpleTemplates::Lexer.new(
        delimiter,
        raw_input
      ).tokenize

      tokens.must_equal [
        token.new(:text, 'string with no placeholders', 0)
      ]
    end

    it 'tokenizes a string with placeholders' do
      raw_input = 'string with <placeholder>'
      tokens = SimpleTemplates::Lexer.new(
        delimiter,
        raw_input
      ).tokenize

      tokens.must_equal [
        token.new(:text, 'string with ', 0),
        token.new(:ph_start, '<', 12),
        token.new(:ph_name, 'placeholder', 13),
        token.new(:ph_end, '>', 24)
      ]
    end

    it 'tokenizes a string with invalid placeholders, containing a new line character' do
      raw_input = "string with <foo\nbar> text"
      tokens = SimpleTemplates::Lexer.new(
        delimiter,
        raw_input
      ).tokenize

      tokens.must_equal [
        token.new(:text, 'string with ', 0),
        token.new(:ph_start, '<', 12),
        token.new(:ph_name, 'foo', 13),
        token.new(:text, "\nbar", 16),
        token.new(:ph_end, '>', 20),
        token.new(:text, ' text', 21)
      ]
    end

    it 'tokenizes a string with invalid placeholders, contains leading and trailing space' do
      raw_input = "string with < foobar > text"
      tokens = SimpleTemplates::Lexer.new(
        delimiter,
        raw_input
      ).tokenize

      tokens.must_equal [
        token.new(:text, 'string with ', 0),
        token.new(:ph_start, '<', 12),
        token.new(:text, ' foobar ', 13),
        token.new(:ph_end, '>', 21),
        token.new(:text, ' text', 22)
      ]
    end

    it 'tokenizes a string with placeholders and a newline character' do
      raw_input = "string with <placeholder>\n Something else"
      tokens = SimpleTemplates::Lexer.new(
        delimiter,
        raw_input
      ).tokenize

      tokens.must_equal [
        token.new(:text, 'string with ', 0),
        token.new(:ph_start, '<', 12),
        token.new(:ph_name, 'placeholder', 13),
        token.new(:ph_end, '>', 24),
        token.new(:text, "\n Something else", 25)
      ]
    end

    it 'tokenizes a string with invalid placeholder and an empty placeholder name' do
      raw_input = "string with <> text"
      tokens = SimpleTemplates::Lexer.new(
        delimiter,
        raw_input
      ).tokenize

      tokens.must_equal [
        token.new(:text, 'string with ', 0),
        token.new(:ph_start, '<', 12),
        token.new(:ph_end, '>', 13),
        token.new(:text, ' text', 14)
      ]
    end
    it 'tokenizes a string with placeholders having a new line character in the placeholder name' do
      raw_input = "string with <placeholder\n> Something else"
      tokens = SimpleTemplates::Lexer.new(
        delimiter,
        raw_input
      ).tokenize

      tokens.must_equal [
        token.new(:text, 'string with ', 0),
        token.new(:ph_start, '<', 12),
        token.new(:ph_name, 'placeholder', 13),
        token.new(:text, "\n", 24),
        token.new(:ph_end, '>', 25),
        token.new(:text, " Something else", 26)
      ]
    end

    it 'tokenizes a string with a placeholder containing numbers' do
      raw_input = 'string with <1placeholder1>'
      tokens = SimpleTemplates::Lexer.new(
        delimiter,
        raw_input
      ).tokenize

      tokens.must_equal [
        token.new(:text, 'string with ', 0),
        token.new(:ph_start, '<', 12),
        token.new(:ph_name, '1placeholder1', 13),
        token.new(:ph_end, '>', 26),
      ]
    end

    it 'tokenizes a string with a placeholder containing underscores' do
      raw_input = 'string with <_place_holder_>'
      tokens = SimpleTemplates::Lexer.new(
        delimiter,
        raw_input
      ).tokenize

      tokens.must_equal [
        token.new(:text, 'string with ', 0),
        token.new(:ph_start, '<', 12),
        token.new(:ph_name, '_place_holder_', 13),
        token.new(:ph_end, '>', 27),
      ]
    end
  end
end
