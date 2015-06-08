module SimpleTemplates
  module Parser
    class Result
      attr_reader :template, :errors, :remaining_tokens

      def initialize(template, errors, remaining_tokens)
        @errors           = errors
        @template         = success? ? template : nil
        @remaining_tokens = remaining_tokens
      end

      def success?
        errors.empty?
      end

      def ==(other)
        template == other.template && errors == other.errors
      end
    end
  end
end
