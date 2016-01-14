require 'simple_templates/parser/error'
require 'simple_templates/parser/placeholder'
require 'simple_templates/parser/text'

module SimpleTemplates
  # Parsing the SimpleTemplate means verifying that there are no malformed tags,
  # and all tags are in the 'allowed' list.
  class Parser

    # A +static+ Hash with the meaning of each tag name
    # @return [Hash{Symbol => String}]
    FRIENDLY_TAG_NAMES = {
      ph_start:        'placeholder start',
      ph_name:         'placeholder name',
      ph_end:          'placeholder end',
      quoted_ph_start: 'quoted placeholder start',
      quoted_ph_end:   'quoted placeholder end',
      text:            'text'
    }.freeze

    # Initializes a new Parser.
    # @param unescapes [SimpleTemplates::Unescapes] a Unescapes object
    # @param tokens <Array[SimpleTemplates::Lexer::Token]> a list of tokens
    # @param allowed_placeholders <Array[String]> a list with allowed
    #   placeholders if is left as nil, then all placeholders are permitted
    def initialize(unescapes, tokens, allowed_placeholders)
      @unescapes            = unescapes.clone.freeze
      @tokens               = tokens.clone.freeze

      @allowed_placeholders = allowed_placeholders &&
        allowed_placeholders.clone.freeze
    end

    # Returns a Parser::Result containing the parsed AST nodes, the errors
    # found when parsing and the remaining tokens that have not been parsed.
    # @return [Array<Array<SimpleTemplates::AST::Node>,
    #   Array<SimpleTemplates::Parser::Error>,
    #   Array<SimpleTemplates::Lexer::Token>>]
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

          if remaining_tokens.nil?
            raise "Parser #{parser.class} shouldn't return nil remaining " +
                  "tokens (should be an Array), please report this bug."
          end

          if errors_result.empty?
            tok_stream = remaining_tokens
            ast        = ast.concat(template)

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

    attr_reader :tokens, :allowed_placeholders, :unescapes

    def invalid_node_content_errors(ast)
      ast.reject(&:allowed?).map do |node|
        Error.new("Invalid #{node.name} with contents, '#{node.contents}' " +
                  "found starting at position #{node.pos}.")
      end
    end

    def acceptable_starting_tokens
      (Placeholder::STARTING_TOKENS | Text::STARTING_TOKENS).map do |tag|
        FRIENDLY_TAG_NAMES[tag]
      end.join(', ')
    end

    def detect_parser(tokens_to_parse)
      toks = tokens_to_parse.clone.freeze

      [Placeholder, Text].each do |parser_class|
        if parser_class.applicable?(toks)
          return parser_class.new(unescapes, toks, allowed_placeholders)
        end
      end

      nil
    end
  end
end
