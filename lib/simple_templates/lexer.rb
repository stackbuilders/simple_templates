require 'strscan'
require 'pry'

module SimpleTemplates

  # The `SimpleTemplates::Lexer` tokenizes the raw input into a more usable form
  # for the `SimpleTemplates::Parser`.
  class Lexer
    Token = Struct.new(:type, :content, :pos)
    PLACEHOLDER_MATCHER = { placeholder: /[a-zA-Z0-9]/ }

    def initialize(delimiter, input)
      @input  = input.clone.freeze
      @matchers = delimiter.to_h.merge(text: /./m).freeze
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
    # Not sure why the attr_reader is not working
    attr_reader :matchers

    # ss for string_scanner
    def next_token(ss)
      if permitted_placeholder?(ss)
        token_type, _pattern = PLACEHOLDER_MATCHER.first
      else
        token_type, _pattern = matchers.find { |_, pattern| ss.check(pattern) }
      end

      Token.new(token_type, ss.matched, ss.pos).tap do
        ss.pos += ss.matched.length
      end
    end

    def permitted_placeholder?(ss)
      tokens.any? &&
        last_token_is_placeholder_or_placeholder_start? &&
        placeholder?(ss)
    end

    def last_token_is_placeholder_or_placeholder_start?
      tokens.last.type == :ph_start || tokens.last.type == :placeholder
    end

    def placeholder?(string_scanner)
      string_scanner.check(PLACEHOLDER_MATCHER.values.first)
    end

    # WIP Still need to change this, no mutation needed
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
