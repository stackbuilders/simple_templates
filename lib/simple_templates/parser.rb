require 'set'

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

    Error = Struct.new(:message)

    def initialize(raw_template, whitelisted_placeholders)
      @tokens                   = Lexer.new(raw_template).tokenize
      @whitelisted_placeholders = whitelisted_placeholders.to_set
    end

    # Returns either a stream of valid tokens (Placeholders and Strings),
    # or an Array containing one or more Errors.
    def parse
      ast, syntax_errors         = *check_syntax
      invalid_placeholder_errors = *check_valid_placeholders(ast)

      ParseResult.new(Template.new(ast),
                      syntax_errors.concat(invalid_placeholder_errors))
    end

    private

    attr_reader :whitelisted_placeholders, :tokens

    # This section verifies the *semantics* of the token stream. In this case,
    # all we care about is that the tokens are in the whitelist.
    def check_valid_placeholders(ast)
      invalid_placeholder_errors(invalid_placeholders(ast))
    end

    def check_syntax
      toks = tokens.clone

      template_nodes = []
      errors         = []

      # This section strictly analyzes the *syntax* of the tokens.
      while toks.any?
        ps = PlaceholderParser.new(toks)

        if ps.applicable?
          res = ps.placeholder
          if res.success?
            toks = toks[3..-1] # pop off the tokens we just used.
            template_nodes.concat(res.template)

          else
            # Once we get a syntax error, we can't really determine if anything
            # else is broken syntactically, so return with the first Error.
            errors.concat(res.errors)
            break

          end
        else
          next_text_node = toks.shift
          template_nodes << AST::Text.new(unescape(next_text_node),
                                           next_text_node.pos)
        end
      end

      # At this point we can do minor cleanup of our structure.
      [compress_adjacent_text_nodes(template_nodes), errors]
    end

    def invalid_placeholder_errors(invalid_pholders)
      invalid_pholders.map do |p|
        Error.new("Invalid placeholder with name, '#{p.contents}' " +
                   "found starting at position #{p.pos}.")
      end
    end

    # Invalid placeholders are ones that are not explicitly whitelisted.
    def invalid_placeholders(template_nodes)
      placeholders(template_nodes).
        reject{|ph| whitelisted_placeholders.include?(ph.contents) }
    end

    def placeholders(template_nodes)
      template_nodes.select{|node| node.placeholder? }.to_set
    end

    def unescape(token)
      UNESCAPES[token.type] || token.content
    end

    def compress_adjacent_text_nodes(template_nodes)
      template_nodes.reduce([]) do |compressed, node|
        if compressed.any? && compressed.last.text? && node.text?
          compressed[0..-2] << compressed[-1] + node
        else
          compressed << node
        end
      end
    end
  end
end
