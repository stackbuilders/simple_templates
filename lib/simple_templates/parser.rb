module SimpleTemplates

  # Parsing the SimpleTemplate means verifying the *syntax* and *semantics* of
  # the template. That is, it shouldn't have malformed tags, and all tags should
  # be in the tag whitelist.
  class Parser

    # After parsing, we get a data structure containing `Placeholder`s
    # and `String`s or an `Array` containing a single `Error`.
    UNESCAPES = {
      lt:  '<',
      gt:  '>',
    }.freeze

    Placeholder = Struct.new(:name, :pos)
    Error       = Struct.new(:message)

    def initialize(raw_template, whitelisted_placeholders)
      @tokens                   = Lexer.new(raw_template).tokenize
      @whitelisted_placeholders = whitelisted_placeholders
    end

    # Returns either a stream of valid tokens (Placeholders and Strings),
    # or an Array containing one or more Errors.
    def parse
      toks = tokens.clone

      template_nodes = []

      # This section strictly analyzes the *syntax* of the tokens.
      while toks.any?
        ps = PlaceholderSyntax.new(toks)

        if ps.applicable?
          case res = ps.placeholder
          when Placeholder
            toks = toks[3..-1] # pop off the tokens we just used.
            template_nodes << res
          else
            # In this case there is a syntactical error, so we don't proceed to
            # do validation of placeholder names since we can't tell what they
            # are with invalid tag syntax! Just return the first syntax error.
            return [res]
          end
        else
          template_nodes << unescape(toks.shift)
        end
      end

      # At this point we can do minor cleanup of our structure.
      template_nodes = compress_adjacent_text_nodes(template_nodes)

      # This section verifies the *semantics* of the token stream. In this case,
      # all we care about is that the tokens are in the whitelist.
      invalids = invalid_placeholders(template_nodes)
      return invalid_placeholder_errors(invalids) unless invalids.empty?

      template_nodes
    end


    private

    attr_reader :whitelisted_placeholders, :tokens

    def invalid_placeholder_errors(invalid_pholders)
      invalid_pholders.map do |p|
        Error.new("Invalid placeholder with name, '#{p.name}' found starting at position #{p.pos}.")
      end
    end

    # Invalid placeholders are ones that are not explicitly whitelisted.
    def invalid_placeholders(template_nodes)
      template_nodes.select do |tn|
        tn.is_a?(Placeholder) && !whitelisted_placeholders.include?(tn.name)
      end
    end

    def unescape(token)
      UNESCAPES[token.type] || token.content
    end

    def compress_adjacent_text_nodes(template_nodes)
      template_nodes.reduce([]) do |compressed, node|
        if !compressed.empty? &&
          compressed.last.is_a?(String) && node.is_a?(String)

          compressed[0..-2] << compressed[-1] + node
        else
          compressed << node
        end
      end
    end
  end
end
