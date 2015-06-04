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

    PH_TAGS = [:ph_start, :ph_end]

    FRIENDLY_TAG_NAMES = {
      ph_start: 'placeholder start',
      ph_end:   'placeholder end',
      lt:       'less than',
      gt:       'greater than',
      text:     'text'
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

    class PlaceholderSyntax
      # We take any sequence of three tokens to see if it's a valid Placeholder.
      # NB: this excludes placeholder names containing escaped sequences. If
      # that becomes necessary later, we'll have to change this approach.
      def initialize(toks)
        @tag_tokens = toks[0..2].compact
      end

      EXPECTED_TAG_ORDER = [:ph_start, :text, :ph_end]

      # If this token sequence starts with a placeholder tag, we can verify
      # whether or not it's valid.
      def applicable?
        PH_TAGS.include?(tag_types.first)
      end

      # If this stream starts with a placeholder token, parse out the
      # Placeholder, or return an Error indicating the syntax problem.
      def placeholder
        raise ArgumentError,
          "Stream does not contain any placeholder tags!" unless applicable?

        expected_order_with_found_tokens = EXPECTED_TAG_ORDER.zip(@tag_tokens)

        expected_order_with_found_tokens.each do |expected_type, found_tag|
          if found_tag.nil?
            return Error.new("Expected #{FRIENDLY_TAG_NAMES.fetch(expected_type)} token, but reached end of input.")

          elsif expected_type != found_tag.type
            return Error.new("Expected #{FRIENDLY_TAG_NAMES.fetch(expected_type)} token at character position #{found_tag.pos}, but found a #{FRIENDLY_TAG_NAMES.fetch(found_tag.type)} token instead.")

          else # This token was expected at this point in the placeholder sequence.
          end
        end

        Placeholder.new(tag_name.content, tag_start.pos)
      end

      private

      attr_reader :tag_tokens

      def tag_types
        tag_tokens.map(&:type)
      end

      def tag_start ; @tag_tokens[0] ; end
      def tag_name  ; @tag_tokens[1] ; end
      def tag_end   ; @tag_tokens[2] ; end
    end
  end
end
