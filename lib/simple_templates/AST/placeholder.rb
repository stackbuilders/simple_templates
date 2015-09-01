require 'simple_templates/AST/node'

module SimpleTemplates
  module AST
    class Placeholder < Node
      def render(context)
        context.public_send(contents)
      end
    end
  end
end
