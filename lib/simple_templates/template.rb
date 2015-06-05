require 'set'

module SimpleTemplates
  class Template

    attr_reader :ast

    def initialize(ast)
      @ast = ast
    end

    # Returns all placeholder names used in the template.
    def placeholder_names
      placeholders(ast).map(&:contents).to_set
    end

    def render(context)
      ast.map { |node| node.render(context) }.join
    end

    def ==(other)
      ast == other.ast
    end

    private

    def placeholders(template_nodes)
      template_nodes.select{|node| node.placeholder? }.to_set
    end
  end
end
