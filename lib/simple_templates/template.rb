require 'set'

module SimpleTemplates

  # A `Template` is a renderable collection of SimpleTemplates::AST nodes.
  class Template

    attr_reader :ast

    def initialize(ast)
      @ast = ast
    end

    # Returns all placeholder names used in the template.
    def placeholder_names
      placeholders.map(&:contents).to_set
    end

    # Accepts a context in which it should be rendered.
    # Substitutes `Placeholder`s with the result of calling methods
    # with the same name on the context `Object`.
    def render(context)
      ast.map { |node| node.render(context) }.join
    end

    def ==(other)
      ast == other.ast
    end

    private

    def placeholders
      ast.select{ |node| node.type_of?('placeholder') }.to_set
    end
  end
end
