module SimpleTemplates
  class Parser

    # After parsing, we get a data structure containing `Placeholder`s
    # and `String`s or an `Array` containing a single `Error`.
    Placeholder = Struct.new(:name)

    UNESCAPES = {
      lt:  '<',
      gt:  '>',
      esc: '\\'
    }.freeze

    Error = Struct.new(:message)

    attr_reader :placeholder_names

    def initialize(raw_template, placeholder_names)
      @tokens            = Lexer.new(raw_template).tokenize
      @placeholder_names = placeholder_names
    end

    def parse
      toks = tokens.clone

      template_nodes = []

      while toks.any?
        case res = placeholder(toks)
        when Placeholder  # We got a valid placeholder.
          toks = toks[3..-1] # pop off the tokens we just used.
          template_nodes << res

        # We found an invalid placeholder, so just return this error.
        when Error then return [ res ]

        when NilClass # This token is *not* a placeholder.

          # Return an error if we find a closing bracket outside of a placeholder.
          if toks[0].type == :ph_end
            return [ Error.new("Unexpected closing bracket found at position #{toks[0].pos}.") ]
          end

          # No other tokens are invalid if we're not in a placeholder, so push
          # this one on after casting as a basic text node.
          template_nodes << unescape(toks.shift)

        else raise "Probable bug in placeholder detection, please report."
        end
      end

      compress_adjacent_text_nodes(template_nodes)
    end

    private

    def unescape(token)
      UNESCAPES[token.type] || token.content
    end

    def compress_adjacent_text_nodes(template_nodes)
      template_nodes.reduce([]) do |compressed, node|
        if !compressed.empty? && compressed.last.is_a?(String) && node.is_a?(String)
          compressed[0..-2] << compressed[-1] + node
        else
          compressed << node
        end
      end
    end

    def placeholder(toks)
      if toks[0].type == :ph_start
        if toks[1] && toks[1].type == :text
          if placeholder_names.include?(toks[1].content)
            if toks[2] && toks[2].type == :ph_end
              Placeholder.new(toks[1].content)
            else
              err = toks[2] ? "Expected closing tag for placeholder which started at position #{toks[0].pos}, but found a #{toks[2].type} instead." :
                      "No closing tag found for placeholder which started at position #{toks[0].pos}."

              Error.new(err)
            end
          else
            Error.new("Invalid placeholder name '#{toks[1].content}' found at position #{toks[1].pos}.")
          end
        else
          Error.new("Expected to find a valid placeholder name at #{toks[1].pos}, but found a #{toks[1].type} instead.")
        end
      else
        nil # the toks at the head of this list do not represent a placeholder sequence.
      end
    end

    attr_reader :tokens
  end
end
