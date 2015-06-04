require 'set'

module SimpleTemplates
  class Template

    attr_reader :ast, :errors

    def initialize(ast, errors)
      @ast    = ast
      @errors = errors
    end

    # Returns all placeholder names used in the template, regardless of whether
    # they're valid or not.
    def placeholder_names
      placeholders(ast).map(&:name).to_set
    end

    def render(context)
      raise ArgumentError, "Unable to render using a template with errors!" if errors.any?

      ast.map do |node|
        case node
        when String then node
        when Parser::Placeholder then context.public_send(node.name)

        else raise "Unable to render template with node type '#{node.class}'!"
        end
      end.join
    end

    def ==(other)
      @ast = other.ast && @errors == other.errors
    end

    private

    def placeholders(template_nodes)
      template_nodes.select{|node| node.is_a?(Parser::Placeholder) }.to_set
    end
  end
end
