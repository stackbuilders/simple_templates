require 'set'

module SimpleTemplates

  # A `Template` is a renderable collection of SimpleTemplates::AST nodes.
  #
  # AST classes are scanned for TemplateMethods module, if it's there, Template
  # is extended with this module.
  class Template

    attr_reader :ast, :errors, :remaining_tokens

    def initialize(ast, errors = [], remaining_tokens = [])
      @ast              = ast.clone.freeze if errors.empty?
      @errors           = errors.clone.freeze
      @remaining_tokens = remaining_tokens.clone.freeze

      [
       SimpleTemplates::AST::Placeholder,
       SimpleTemplates::AST::Text
      ].each do |ast_class|
        if ast_class.const_defined?(:TemplateMethods)
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
  end
end
