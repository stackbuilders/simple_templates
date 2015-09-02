require 'set'

require 'simple_templates/parser/node_parser'
require 'simple_templates/AST/text'

module SimpleTemplates
  class Parser
    class Text < NodeParser

      STARTING_TOKENS = Set[:quoted_ph_start, :quoted_ph_end, :text]

      UNESCAPE_METHODS = {
        quoted_ph_start: :start,
        quoted_ph_end:   :end
      }

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
        unescapes[UNESCAPE_METHODS[token.type]] || token.content
      end
    end
  end
end
