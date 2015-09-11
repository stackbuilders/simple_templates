require 'strscan'

module SimpleTemplates

  # The `SimpleTemplates::Lexer` tokenizes the raw input into a more usable form
  # for the `SimpleTemplates::Parser`.

  class Lexer
    Token = Struct.new(:type, :content, :pos)

    VALID_PLACEHOLDER = { ph_name: /[A-Za-z0-9_]+/ }.freeze
    # Create a new instance of the lexer
    # @param delimiter [Delimiter] the delimiter object
    # @param input [String]
    def initialize(delimiter, input)
      @input    = input.clone.freeze
      @matchers = delimiter.to_h.merge(text: /./m).freeze
      @matchers_with_placeholder_name = VALID_PLACEHOLDER.merge(@matchers)
    end

    # Tokenizes the raw input
    # @return [Array<Token>]
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

    # Generate the next token, checking the input tokens match with the pattern
    # and mov the ss to the next position
    # @param tokens [Array<Token>] the array of tokens
    # @param ss [String] the string scanner
    # @return [Token] the next token
    def next_token(tokens, ss)
      token_type, pattern = current_matchers(tokens).
                              find { |_, pattern| ss.check(pattern) }

      Token.new(token_type, ss.matched, ss.pos).tap do
        ss.pos += ss.matched.length
      end
    end

    # Check if there is any tokens
    # (see #next_token)
    # @param tokens [Array<Token>] the array of token
    # @return [Hash <Symbol,Regexp>]
    def current_matchers(tokens)
      if tokens.any? && tokens.last.type == :ph_start
        @matchers_with_placeholder_name
      else
        @matchers
      end
    end
  end
end
