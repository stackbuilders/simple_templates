require 'set'

require 'simple_templates/parser/node_parser'
require 'simple_templates/AST/text'

module SimpleTemplates
  class Parser
    class Text < NodeParser

      STARTING_TOKENS = Set[:lt, :gt, :text]

      # After parsing, we get a data structure containing `Placeholder`s
      # and `String`s or an `Array` containing a single `Error`.
      UNESCAPES = {
        lt:  '<',
        gt:  '>',
      }.freeze

      def parse
        txt_node = nil
        toks     = tokens.dup

        while self.class.applicable?(toks)
          next_txt_token = toks.shift

          this_txt_node =
            AST::Text.new(unescape(next_txt_token), next_txt_token.pos, true)

          txt_node = txt_node.nil? ? this_txt_node : txt_node + this_txt_node
        end

        [[txt_node], [], toks]
      end

      private

      def unescape(token)
        UNESCAPES[token.type] || token.content
      end
    end
  end
end
