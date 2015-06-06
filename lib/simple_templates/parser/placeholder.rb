require 'set'

module SimpleTemplates
  module Parser
    # Recognizes a set of input tokens as a Placeholder.
    class Placeholder < Base

      EXPECTED_TAG_ORDER = [:ph_start, :text, :ph_end]

      def self.starting_tokens
        [:ph_start].to_set
      end

      # If this stream starts with a placeholder token, parse out the
      # Placeholder, or a Result with errors indicating the syntax problem.
      def parse
        errors = check_placeholder_syntax

        placeholder_ast = if errors.empty?
          remaining_tokens = tokens[3..-1]

          valid = whitelisted_placeholders.include?(tag_name.content)

          [AST::Placeholder.new(tag_name.content, tag_start.pos, valid)]
        else
          [] # we don't have an AST portion to return if we encountered errors
        end

        Parser::Result.new(placeholder_ast, errors, remaining_tokens)
      end

      private

      def check_placeholder_syntax
        expected_order_with_found_tokens = EXPECTED_TAG_ORDER.zip(tag_tokens)

        errors = expected_order_with_found_tokens.
                   reduce([]) do |errs, (expected_type, found_tag)|

          if found_tag.nil?
            break errs << Parser::Error.new(
              "Expected #{FRIENDLY_TAG_NAMES.fetch(expected_type)} token, but" +
              " reached end of input.")

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

      def tag_tokens
        tokens[0..2].compact
      end

      def tag_start
        tokens[0]
      end

      def tag_name
        tokens[1]
      end

      def tag_types
        tag_tokens.map(&:type)
      end
    end
  end
end
