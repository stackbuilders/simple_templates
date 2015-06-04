require 'strscan'

module SimpleTemplates
  class Lexer
    Token = Struct.new(:type, :content, :pos)

    TOKENS = {
      lt:        /\\</,
      gt:        /\\>/,
      ph_start:  /\</,
      ph_end:    /\>/
    }.freeze

    def initialize(input)
      @ss = StringScanner.new(input)
    end

    def tokenize
      tokens = []

      until @ss.eos?
        tok = next_token

        if !tokens.empty? && tok.type == :text && tokens.last.type == :text
          tokens.last.content += tok.content
        else
          tokens << tok
        end
      end

      tokens
    end


    private

    def next_token
      pos = @ss.pos

      TOKENS.each do |token_type, pattern|
        if matched = @ss.scan(pattern)
          return Token.new(token_type, matched, pos)
        end
      end

      Token.new(:text, @ss.getch, pos)
    end
  end
end
