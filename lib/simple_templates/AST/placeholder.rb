require 'simple_templates/AST/node'

module SimpleTemplates
  module AST
    class Placeholder < Node
      module TemplateMethods
        def placeholders
          ast.select{ |node| SimpleTemplates::AST::Placeholder === node }.to_set
        end
      end

      def render(context)
        context.public_send(contents)
      end
    end
  end
end
