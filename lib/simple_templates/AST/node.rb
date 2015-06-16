module SimpleTemplates
  module AST
    class Node
      attr_reader :contents, :pos, :valid

      def initialize(contents, pos, valid)
        @contents = contents
        @pos      = pos
        @valid    = valid
      end

      def ==(other)
        contents == other.contents && pos == other.pos && valid == other.valid
      end

      def valid?
        valid
      end

      def type
        self.class.to_s.split(/::/).last.downcase
      end

      def type_of?(check)
        type == check.to_s
      end

      # :nocov:
      def render(context)
        raise NotImplementedError
      end
      # :nocov:
    end
  end
end
