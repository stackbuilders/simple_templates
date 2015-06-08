require 'simple_templates/template'

require 'simple_templates/parser/base'
require 'simple_templates/parser/placeholder'
require 'simple_templates/parser/text'

module SimpleTemplates
  module Parser
    # Parsing the SimpleTemplate means verifying the *syntax* and *semantics* of
    # the template. That is, it shouldn't have malformed tags, and all tags should
    # be in the tag whitelist.
    class Template < Base

      # Returns a Parser::Result containing a Template if parsing was successful,
      # or any Errors that were encountered.
      def parse
        ast    = []
        errors = []

        while tokens.any?
          parser = detect_parser(tokens)

          if parser.nil?
            errors <<
              Error.new("Encountered unexpected token in stream " +
                "(#{FRIENDLY_TAG_NAMES[tokens.first.type]}), but expected to " +
                "see one of the following types: #{acceptable_starting_tokens}.")
              @tokens = []

          else
            res = parser.parse
            if res.success?
              @tokens = res.remaining_tokens
              ast = ast.concat(res.template)

            else
              # Once we get a syntax error, we can't really determine if anything
              # else is broken syntactically, so return with the first Error.
              @tokens = []
              errors.concat(res.errors)

            end
          end
        end

        errors.concat(invalid_node_content_errors(ast))
        Parser::Result.new(SimpleTemplates::Template.new(ast), errors, tokens)
      end

      private

      def invalid_node_content_errors(ast)
        ast.reject(&:valid?).map do |node|
          Error.new("Invalid #{node.type} with contents, '#{node.contents}' " +
          "found starting at position #{node.pos}.")
        end
      end

      def acceptable_starting_tokens
        (Placeholder.starting_tokens | Text.starting_tokens).map do |tag|
          FRIENDLY_TAG_NAMES[tag]
        end.join(', ')
      end

      def detect_parser(toks)
        [Placeholder, Text].each do |parser_class|
          if parser_class.applicable?(tokens)
            return parser_class.new(tokens, whitelisted_placeholders)
          end
        end

        nil
      end
    end
  end
end
