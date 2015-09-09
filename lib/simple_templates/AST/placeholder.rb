require 'simple_templates/AST/node'

module SimpleTemplates
  module AST
    class Placeholder < Node
      def render(substitutions)
        if allowed?
          substitutions.fetch(contents.to_sym)
        else
          raise 'Unable to render invalid placeholder!'
        end
      end
    end
  end
end
