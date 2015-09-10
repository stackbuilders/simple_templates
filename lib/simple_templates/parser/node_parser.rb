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

      def initialize(unescapes, tokens, allowed_placeholders = nil)
        @unescapes                = unescapes.to_h.clone.freeze
        @tokens                   = tokens.clone.freeze

        # Placeholders to match are mapped to strings for our validity checks.
        # This is because if we go the other way and convert all possible
        # placeholder names to symbols before comparing to the whitelist, we
        # could cause a memory leak by allocating an infinite amount of symbols
        # that won't be garbage-collected.
        @allowed_placeholders = allowed_placeholders &&
                                allowed_placeholders.map(&:to_s).freeze
      end

      private

      attr_reader :tokens, :allowed_placeholders, :unescapes
    end
  end
end
