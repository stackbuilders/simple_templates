require_relative "../test_helper"

describe SimpleTemplates::Lexer do
  Token = Struct.new(:type, :content, :pos)

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
        SimpleTemplates::Lexer::Token.new(:placeholder, '<placeholder>', 12)
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
        SimpleTemplates::Lexer::Token.new(:placeholder, '<placeholder>', 12),
        SimpleTemplates::Lexer::Token.new(:text, "\n Something else", 25)
      ]
    end
  end
end
