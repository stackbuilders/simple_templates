require 'set'

module SimpleTemplates

  # A `Template` is a renderable collection of SimpleTemplates::AST nodes.
  class Template

    attr_reader :ast, :errors, :remaining_tokens

    def initialize(ast = [], errors = [], remaining_tokens = [])
      @ast              = ast.clone.freeze
      @errors           = errors.clone.freeze
      @remaining_tokens = remaining_tokens.clone.freeze
    end

    # Returns all placeholder names used in the template.
    def placeholder_names
      placeholders.map(&:contents).to_set
    end

    # Accepts a context in which it should be rendered.
    # Substitutes `Placeholder`s with the result of calling methods
    # with the same name on the context `Object`.
    def render(context)
      raise errors unless errors.empty?
      ast.map { |node| node.render(context) }.join
    end

    def placeholders
      ast.select{ |node| SimpleTemplates::AST::Placeholder === node }.to_set
    end

    def ==(other)
      ast == other.ast &&
        errors == other.errors &&
        remaining_tokens == other.remaining_tokens
    end
  end
end
