module SimpleTemplates
  module Parser
    class Text < Base

      def self.starting_tokens
        [:lt, :gt, :text].to_set
      end

      # After parsing, we get a data structure containing `Placeholder`s
      # and `String`s or an `Array` containing a single `Error`.
      UNESCAPES = {
        lt:  '<',
        gt:  '>',
      }.freeze

      def parse
        text_token = nil

        while applicable?
          next_text_node = @tokens.shift
          unescaped = unescape(next_text_node)

          content, pos = if text_token.nil?
            [unescaped, next_text_node.pos]
          else
            [text_token.contents + unescaped, text_token.pos]
          end

          text_token = AST::Text.new(content, pos, true)
        end

        Parser::Result.new([text_token], [], tokens)
      end

      private

      def unescape(token)
        UNESCAPES[token.type] || token.content
      end
    end
  end
end
