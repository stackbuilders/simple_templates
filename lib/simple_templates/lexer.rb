require 'strscan'

module SimpleTemplates

  # The +SimpleTemplates::Lexer+ tokenizes the raw input into a more usable form
  # for the +SimpleTemplates::Parser+.

  class Lexer

    # A +Struct+ for a Lexer::Token that takes the type, the content and
    # position of a token
    Token = Struct.new(:type, :content, :pos)

    # A Hash with the allowed +Regexp+ for a valid placeholder name
    # @return [Hash{Symbol => Regexp}] a hash with the allowed Regexp for the
    #   placeholder name +:ph_name+
    VALID_PLACEHOLDER = { ph_name: /[A-Za-z0-9_]+/ }.freeze

    # Initializes a new Lexer
    # @param delimiter [SimpleTemplates::Delimiter] a delimiter object
    # @param input [String] a raw input for the lexer
    def initialize(delimiter, input)
      @input    = input.clone.freeze
      @matchers = delimiter.to_h.merge(text: /./m).freeze
      @matchers_with_placeholder_name = VALID_PLACEHOLDER.merge(@matchers)
    end

    # Tokenizes the raw input and returns a list of tokens
    # @return <Array[SimpleTemplates::Lexer::Token]>
    def tokenize
      tokens = []
      ss = StringScanner.new(@input)

      until ss.eos?
        tok = next_token(tokens, ss)

        if tokens.any? && tok.type == :text && tokens.last.type == :text
          tokens.last.content += tok.content
        else
          tokens << tok
        end
      end

      tokens
    end

    private

    # Returns a new token and moves to the next position in the +StringScanner+
    # @param tokens <Array[SimpleTemplates::Lexer::Token]> list of tokens
    # @param ss [StringScanner] a +StringScanner+ for the input
    # @return [SimpleTemplates::Lexer::Token] the next token
    def next_token(tokens, ss)
      token_type, pattern = current_matchers(tokens).
                              find { |_, pattern| ss.check(pattern) }

      Token.new(token_type, ss.matched, ss.pos).tap do
        ss.pos += ss.matched.length
      end
    end

    # Checks if the last token was the start of a placeholder to use include
    #   the placeholder name +:ph_name+ in the hash of matchers
    # @param tokens <Array[SimpleTemplates::Lexer::Token]> the list of tokens
    # @return [Hash {Symbol => Regexp}]
    # (see #next_token)
    def current_matchers(tokens)
      if tokens.any? && tokens.last.type == :ph_start
        @matchers_with_placeholder_name
      else
        @matchers
      end
    end
  end
end
