module SimpleTemplates
  module AST
    class Node
      attr_reader :contents, :pos, :allowed

      def initialize(contents, pos, allowed)
        @contents = contents
        @pos      = pos
        @allowed  = allowed
      end

      def ==(other)
        contents == other.contents && pos == other.pos && allowed == other.allowed
      end

      def allowed?
        allowed
      end

      # :nocov:
      def render(context)
        raise NotImplementedError
      end
      # :nocov:
    end
  end
end
