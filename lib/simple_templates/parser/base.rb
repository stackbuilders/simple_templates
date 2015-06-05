module SimpleTemplates
  module Parser
    class Base

      FRIENDLY_TAG_NAMES = {
        ph_start: 'placeholder start',
        ph_end:   'placeholder end',
        lt:       'less than',
        gt:       'greater than',
        text:     'text'
      }.freeze

      def self.starting_tokens
        raise NotImplementedError
      end

      def initialize(tokens, whitelisted_placeholders, ast = [])
        @ast                      = ast.clone
        @tokens                   = tokens.clone
        @whitelisted_placeholders = whitelisted_placeholders.clone
      end

      def applicable?
        tokens.any? && self.class.starting_tokens.include?(tokens.first.type)
      end

      private

      attr_reader :ast, :tokens, :whitelisted_placeholders
    end
  end
end
