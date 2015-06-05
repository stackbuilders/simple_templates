module SimpleTemplates

  # Recognizes a set of input tokens as a Placeholder.
  class PlaceholderParser

    PH_TAGS = [:ph_start, :ph_end]

    FRIENDLY_TAG_NAMES = {
      ph_start: 'placeholder start',
      ph_end:   'placeholder end',
      lt:       'less than',
      gt:       'greater than',
      text:     'text'
    }.freeze

    EXPECTED_TAG_ORDER = [:ph_start, :text, :ph_end]

    # We take any sequence of three tokens to see if it's a valid Placeholder.
    # NB: this excludes placeholder names containing escaped sequences. If
    # that becomes necessary later, we'll have to change this approach.
    def initialize(toks)
      @tag_start, @tag_name, @tag_end = @tag_tokens = toks[0..2].compact
    end

    # If this token sequence starts with a placeholder tag, we can verify
    # whether or not it's valid.
    def applicable?
      PH_TAGS.include?(tag_types.first)
    end

    # If this stream starts with a placeholder token, parse out the
    # Placeholder, or return an Error indicating the syntax problem.
    def parse
      raise ArgumentError,
        "Stream does not contain any placeholder tags!" unless applicable?

      errors = check_placeholder_syntax

      placeholder_ast = errors.empty? ?
        [AST::Placeholder.new(tag_name.content, tag_start.pos)] : []

      ParseResult.new(placeholder_ast, errors)
    end

    private

    attr_reader :tag_tokens, :tag_start, :tag_name, :tag_end

    def check_placeholder_syntax
      expected_order_with_found_tokens = EXPECTED_TAG_ORDER.zip(@tag_tokens)

      errors = expected_order_with_found_tokens.
                 reduce([]) do |errs, (expected_type, found_tag)|

        if found_tag.nil?
          break errs << Parser::Error.new(
          "Expected #{FRIENDLY_TAG_NAMES.fetch(expected_type)} token, but " +
          "reached end of input.")

        elsif expected_type != found_tag.type
          break errs << Parser::Error.new(
          "Expected #{FRIENDLY_TAG_NAMES.fetch(expected_type)} token at " +
          "character position #{found_tag.pos}, but found a " +
          "#{FRIENDLY_TAG_NAMES.fetch(found_tag.type)} token instead.")

        else
          # This token was expected at this point in the placeholder sequence,
          # no need to add errors.
          errs
        end
      end
    end

    def tag_types
      tag_tokens.map(&:type)
    end
  end
end
