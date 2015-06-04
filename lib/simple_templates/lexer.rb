require 'strscan'

module SimpleTemplates
  class Lexer
    Token = Struct.new(:type, :content, :pos)

    TOKENS = {
      lt:        /\\</,
      gt:        /\\>/,
      esc:       /\\/,
      ph_start:  /\</,
      ph_end:    /\>/
    }.freeze

    def initialize(input)
      @ss = StringScanner.new(input)
    end

    def tokenize
      tokens = []
      text, start_text_pos = '', 0

      until @ss.eos?
        if tok = next_token
          unless text.empty?
            tokens << Token.new(:text, text, start_text_pos)
            text = ''
          end

          tokens << tok
        else
          start_text_pos = @ss.pos if text.empty?
          text += @ss.getch
        end
      end

      text.empty? ? tokens : tokens << Token.new(:text, text, start_text_pos)
    end

    private

    def next_token
      pos = @ss.pos

      TOKENS.each do |token_type, pattern|
        if matched = @ss.scan(pattern)
          return Token.new(token_type, matched, pos)
        end
      end

      nil
    end
  end
end
