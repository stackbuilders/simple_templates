require 'strscan'

module SimpleTemplates

  # The `SimpleTemplates::Lexer` tokenizes the raw input into a more usable form
  # for the `SimpleTemplates::Parser`.
  class Lexer
    Token = Struct.new(:type, :content, :pos)
    PLACEHOLDER_MATCHER = { placeholder: /./m }

    def initialize(delimiter, input)
      @input  = input.clone.freeze
      @matchers = delimiter.to_h
      @tokens = []
    end

    def tokenize
      ss = StringScanner.new(@input)

      until ss.eos?
        tok = next_token(ss)
        consolidate_tokens(tok)
      end

      tokens
    end

    private

    attr_accessor :tokens

    def next_token(ss)
      token_type, _pattern = @matchers.find { |_, pattern| ss.check(pattern) }

      Token.new(token_type, ss.matched, ss.pos).tap do
        ss.pos += ss.matched.length
      end
    end

    def consolidate_tokens(token)
      if tokens.any? && token.type == :text && tokens.last.type == :text
        tokens.last.content += token.content
      elsif token.type == :ph_start
        token.type = :placeholder
        @matchers = PLACEHOLDER_MATCHER.merge(@matchers)
      elsif tokens.any? && token.type == :placeholder && tokens.last.type == :placeholder
        tokens.last.content += token.content
      elsif token.type == :ph_end
        token.type = :placeholder
        @matchers.shift
      else
        tokens << token
      end
    end
  end
end
