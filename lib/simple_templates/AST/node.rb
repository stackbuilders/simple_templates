module SimpleTemplates
  module AST
    class Node
      attr_reader :contents, :pos, :valid

      def initialize(contents, pos, valid)
        @contents = contents
        @pos      = pos
        @valid    = valid
      end

      def render(context)
        raise NotImplementedError
      end

      def ==(other)
        contents == other.contents && pos == other.pos && valid == other.valid
      end

      def placeholder?
        raise NotImplementedError
      end

      def text?
        raise NotImplementedError
      end

      def type
        raise NotImplementedError
      end

      def valid?
        valid
      end
    end
  end
end
