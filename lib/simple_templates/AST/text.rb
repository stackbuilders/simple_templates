require 'simple_templates/AST/node'

module SimpleTemplates
  module AST
    #
    # A Text specialized Node that implements the +render+ method for text
    # inputs
    #
    class Text < Node
      # Renders the content of the node. It doesn't use the context just takes
      # the class contents.
      # @param context [Hash{ Symbol => String }]
      # @return [String] returns the +contents+ of the class since it doesn't
      #   apply any substitution
      def render(context)
        contents
      end

      # Appends the content of the Text node to another node, keeping the
      # position and checking if both are allowed or not.
      # @param other [SimpleTemplates::AST::Text]
      # @return [SimpleTemplates::AST::Text]
      def +(other)
        Text.new(contents + other.contents, pos, allowed && other.allowed)
      end
    end
  end
end
