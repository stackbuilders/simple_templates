require 'strscan'

module SimpleTemplates

  # The `SimpleTemplates::Lexer` tokenizes the raw input into a more usable form
  # for the `SimpleTemplates::Parser`.
  class Lexer
    Token = Struct.new(:type, :content, :pos)


    TOKENS = {
      lt:        /\\</,
      gt:        /\\>/,
      ph_start:  /\</,
      ph_end:    /\>/,
      text:      /./
    }.freeze

    def initialize(input)
      @ss = StringScanner.new(input)
    end

    def tokenize
      tokens = []

      until @ss.eos?
        tok = next_token

        if tokens.any? && tok.type == :text && tokens.last.type == :text
          tokens.last.content += tok.content
        else
          tokens << tok
        end
      end

      tokens
    end


    private

    def next_token
      token_type, pattern = TOKENS.find { |_, pattern| @ss.check(pattern) }

      Token.new(token_type, @ss.matched, @ss.pos).tap do
        @ss.pos += @ss.matched.length
      end
    end
  end
end
