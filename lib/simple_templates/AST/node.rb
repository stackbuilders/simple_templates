module SimpleTemplates
  module AST
    class Node
      attr_reader :contents, :pos

      def initialize(contents, pos)
        @contents = contents
        @pos      = pos
      end

      def render(context)
        raise NotImplementedError
      end

      def ==(other)
        contents == other.contents && pos == other.pos
      end
    end
  end
end
