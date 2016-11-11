require 'simple_templates/AST/node'

module SimpleTemplates
  module AST
    #
    # A Placeholder specialized Node that implements the +render+ method for
    # placeholders
    #
    class Placeholder < Node
      #
      # Renders the substitutions in the input.
      # Raises and error if it verifies it's not allowed. (see allowed?)
      # @param substitutions [Hash{ Symbol => String }]
      # @return [String] the content of the placeholder
      #
      def render(substitutions)
        if allowed?
          substitutions.fetch(contents.to_sym)
        else
          raise 'Unable to render invalid placeholder!'
        end
      rescue KeyError
        raise InterpolationError.new(
          "\"#{contents}\" key missing. Unable to render \"#{contents}\" placeholder.")
      end
    end

    class InterpolationError < RuntimeError; end
  end
end
