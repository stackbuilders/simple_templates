require 'set'

require 'simple_templates/parser/node_parser'
require 'simple_templates/AST/text'

module SimpleTemplates
  class Parser
    #Recognizes a set of input tokens as a Text
    class Text < NodeParser

      # The starting tokens that the input can have
      # @return [Set<Symbol>]
      STARTING_TOKENS = Set[:quoted_ph_start, :quoted_ph_end, :text]

      # A hash containing the method for a quoted placeholder start or end
      # @return [Hash{ Symbol => Symbol }]
      UNESCAPE_METHODS = {
        quoted_ph_start: :start,
        quoted_ph_end:   :end
      }

      # It parses the stream, if it starts with a text node then it parses out
      # the text until it is not applicable for the input anymore
      # @return <Array <Array[SimpleTemplates::AST::Text]>,
      #   <Array>,
      #   <Array[SimpleTemplates::Lexer::Token]>> an +Array+ with a list of
      #   AST::Text as first element, always an Empty list of Errors and the
      #   remaining unparsed tokens
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
