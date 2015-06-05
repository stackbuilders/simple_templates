module SimpleTemplates
  module AST
    class Text < Node
      def render(context)
        contents
      end

      def +(other)
        Text.new(contents + other.contents, pos)
      end
    end
  end
end
