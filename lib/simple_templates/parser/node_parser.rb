require 'simple_templates/parser/error'

require 'set'

module SimpleTemplates
  class Parser
    class NodeParser

      # The Base class doesn't accept any tokens for parsing, since it isn't
      # supposed to be instantiated.
      STARTING_TOKENS = Set[]

      def self.applicable?(tokens)
        tokens.any? && self::STARTING_TOKENS.include?(tokens.first.type)
      end

      def initialize(unescapes, tokens, whitelisted_placeholders)
        @unescapes                = unescapes.to_h.clone.freeze
        @tokens                   = tokens.clone.freeze
        @whitelisted_placeholders = whitelisted_placeholders.clone.freeze
      end

      private

      attr_reader :tokens, :whitelisted_placeholders, :unescapes
    end
  end
end
