require 'simple_templates/AST/node'

module SimpleTemplates
  module AST
    class Text < Node
      def render(context)
        contents
      end

      def +(other)
        Text.new(contents + other.contents, pos, valid && other.valid)
      end
    end
  end
end
