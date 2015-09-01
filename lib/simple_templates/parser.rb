require 'simple_templates/template'
require 'simple_templates/parser/placeholder'
require 'simple_templates/parser/text'

module SimpleTemplates
  # Parsing the SimpleTemplate means verifying the *syntax* and *semantics* of
  # the template. That is, it shouldn't have malformed tags, and all tags should
  # be in the tag whitelist.
  class Parser

      FRIENDLY_TAG_NAMES = {
        ph_start: 'placeholder start',
        ph_end:   'placeholder end',
        lt:       'less than',
        gt:       'greater than',
        text:     'text'
      }.freeze

      def initialize(tokens, whitelisted_placeholders)
        @tokens                   = tokens.clone.freeze
        @whitelisted_placeholders = whitelisted_placeholders.clone.freeze
      end

      # Returns a Parser::Result containing a Template if parsing was successful,
      # or any Errors that were encountered.
      def parse
        ast    = []
        errors = []

        tok_stream = tokens.dup

        while tok_stream.any?
          parser = detect_parser(tok_stream)

          if parser.nil?
            errors <<
              Error.new("Encountered unexpected token in stream " +
                "(#{FRIENDLY_TAG_NAMES[tok_stream.first.type]}), but expected to " +
                "see one of the following types: #{acceptable_starting_tokens}.")
              tok_stream = []

          else
            template, errors_result, remaining_tokens = parser.parse
            if errors_result.empty?
              tok_stream = remaining_tokens
              ast = ast.concat(template)

            else
              # Once we get a syntax error, we can't really determine if anything
              # else is broken syntactically, so return with the first Error.
              tok_stream = []
              errors.concat(errors_result)

            end
          end
        end

        errors.concat(invalid_node_content_errors(ast))

        [ast, errors, tok_stream]
      end

      private

      attr_reader :tokens, :whitelisted_placeholders

      def invalid_node_content_errors(ast)
        ast.reject(&:valid?).map do |node|
          Error.new("Invalid #{node.class} with contents, '#{node.contents}' " +
          "found starting at position #{node.pos}.")
        end
      end

      def acceptable_starting_tokens
        (Placeholder::STARTING_TOKENS | Text::STARTING_TOKENS).map do |tag|
          FRIENDLY_TAG_NAMES[tag]
        end.join(', ')
      end

      def detect_parser(tokens_to_parse)
        toks = tokens_to_parse.clone

        [Placeholder, Text].each do |parser_class|
          if parser_class.applicable?(toks)
            return parser_class.new(toks, whitelisted_placeholders)
          end
        end

        nil
      end
  end
end
