module SimpleTemplates
  # A module with the Abstract Syntax Tree for The Templates
  module AST
    #
    # Parent class for a node in the AST.
    # This  class is not supposed to be instantiated
    #
    # @!attribute [r] contents
    #   @return [String] the content of the node
    # @!attribute [r] pos
    #   @return [Number] the position of the content in the input
    # @!attribute [r] allowed
    #   @return [Boolean] if the node is allowed. (see allowed?)
    class Node
      attr_reader :contents, :pos, :allowed

      # Initializes a new Node. Please note that this class is not supposed to
      # be instantiated
      # @param contents [String] the content of the node
      # @param pos [Numbers] the position of the content in the input
      # @param allowed [Boolean] if the node is allowed
      def initialize(contents, pos, allowed)
        @contents = contents
        @pos      = pos
        @allowed  = allowed
      end

      # Compares the node to other node by comparing the attributes of the
      # objects
      # @param other [SimpleTemplates::AST::Node]
      # @return [Boolean]
      def ==(other)
        contents == other.contents && pos == other.pos && allowed == other.allowed
      end

      # Checks if the Node is allowed by returning the value in the class
      # attribute +allowed+
      def allowed?
        allowed
      end

      # Returns only the name of the class without the namespace
      # @return [String]
      def name
        self.class.to_s.split('::').last
      end

      # Not implemented method to render a Node that must be especialized by
      # the class inheriting from this class.
      # @param context [Hash{ Symbol => String }]
      # @return [String] substituded contexts
      # :nocov:
      def render(context)
        raise NotImplementedError
      end
      # :nocov:
    end
  end
end
