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

    class Node
      attr_reader :contents, :pos

      def initialize(contents, pos)
        @contents = contents
        @pos      = pos
      end

      def render(context)
        raise NotImplementedError
      end

      def ==(other)
        contents == other.contents && pos == other.pos
      end
    end

    class Placeholder < Node
      def render(context)
        context.public_send(contents)
      end
    end

    class Text < Node
      def render(context)
        contents
      end

      def +(other)
        Text.new(contents + other.contents, pos)
      end
    end

    Error = Struct.new(:message)

    def initialize(raw_template, whitelisted_placeholders)
      @tokens                   = Lexer.new(raw_template).tokenize
      @whitelisted_placeholders = whitelisted_placeholders.to_set
    end

    # Returns either a stream of valid tokens (Placeholders and Strings),
    # or an Array containing one or more Errors.
    def parse
      ast, errors = *parse_and_validate

      if errors.empty?
        invalid_ph_msgs = invalid_placeholder_errors(invalid_placeholders(ast))

        # This section verifies the *semantics* of the token stream. In this case,
        # all we care about is that the tokens are in the whitelist.

        invalid_ph_msgs.empty? ? ParseResult.new(Template.new(ast), []) :
          ParseResult.new(nil, invalid_ph_msgs)

      else

        # We found a syntax error - no need to do semantic analysis since we
        # don't know what's going on, so just return the syntax errors.
        ParseResult.new(nil, errors)
      end
    end


    private

    attr_reader :whitelisted_placeholders, :tokens

    def parse_and_validate
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
            return [template_nodes, [res]]
          end
        else
          next_text_node = toks.shift
          template_nodes << Text.new(unescape(next_text_node), next_text_node.pos)
        end
      end

      # At this point we can do minor cleanup of our structure.
      [compress_adjacent_text_nodes(template_nodes), []]
    end

    def invalid_placeholder_errors(invalid_pholders)
      invalid_pholders.map do |p|
        Error.new("Invalid placeholder with name, '#{p.contents}' found starting at position #{p.pos}.")
      end
    end

    # Invalid placeholders are ones that are not explicitly whitelisted.
    def invalid_placeholders(template_nodes)
      placeholders(template_nodes).
        reject{|ph| whitelisted_placeholders.include?(ph.contents)}
    end

    def placeholders(template_nodes)
      template_nodes.select{|node| node.is_a?(Placeholder) }.to_set
    end

    def unescape(token)
      UNESCAPES[token.type] || token.content
    end

    def compress_adjacent_text_nodes(template_nodes)
      template_nodes.reduce([]) do |compressed, node|
        if compressed.last.respond_to?(:+) && node.respond_to?(:+)
          compressed[0..-2] << compressed[-1] + node
        else
          compressed << node
        end
      end
    end
  end
end
