module SimpleTemplates
  module AST
    class Text < Node
      def render(context)
        contents
      end

      def +(other)
        Text.new(contents + other.contents, pos)
      end

      def placeholder?
        false
      end

      def text?
        true
      end

      def type
        'text'
      end
    end
  end
end
