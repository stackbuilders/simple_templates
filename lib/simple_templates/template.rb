require 'set'

module SimpleTemplates

  # A `Template` is a renderable collection of SimpleTemplates::AST nodes.
  class Template

    attr_reader :ast, :errors, :remaining_tokens

    def initialize(ast, errors = [], remaining_tokens = [])
      @ast              = ast.clone.freeze if errors.empty?
      @errors           = errors.clone.freeze
      @remaining_tokens = remaining_tokens.clone.freeze

      @ast.map(&:class).uniq.each do |ast_class|
        if ast_class.const_get(:TemplateMethods)
          extend(ast_class.const_get(:TemplateMethods))
        end
      end
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

    def ==(other)
      ast == other.ast
    end

    private

    def placeholders
      Set.new
    end
  end
end
