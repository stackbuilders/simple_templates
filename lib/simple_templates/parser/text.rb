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
        txt_node = nil

        while applicable?
          next_txt_token = @tokens.shift

          this_txt_node =
            AST::Text.new(unescape(next_txt_token), next_txt_token.pos, true)

          txt_node = txt_node.nil? ? this_txt_node : txt_node + this_txt_node
        end

        Parser::Result.new([txt_node], [], tokens)
      end

      private

      def unescape(token)
        UNESCAPES[token.type] || token.content
      end
    end
  end
end
