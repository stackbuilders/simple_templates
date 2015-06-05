module SimpleTemplates
  module AST
    class Placeholder < Node
      def render(context)
        context.public_send(contents)
      end

      def placeholder?
        true
      end

      def text?
        false
      end

      def type
        'placeholder'
      end
    end
  end
end
