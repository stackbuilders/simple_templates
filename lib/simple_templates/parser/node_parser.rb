require 'set'

module SimpleTemplates
  class Parser
    # A Base class for the Placeholders and Text parsers
    class NodeParser

      # The Base class doesn't accept any tokens for parsing, since it isn't
      # supposed to be instantiated.
      # @return [Set<Object>]
      STARTING_TOKENS = Set[]

      # Checks if the class is applicable for the first token in the list
      # @param tokens <Array[SimpleTemplates::Lexer::Token]> a list of tokens
      def self.applicable?(tokens)
        tokens.any? && self::STARTING_TOKENS.include?(tokens.first.type)
      end

      # Initializes a new NodeParser. Please note that this class is not
      # supposed to be instantiated
      # @param unescapes [SimpleTemplates::Unescapes] a Unescapes object
      # @param tokens <Array[SimpleTemplates::Lexer::Token]> a list of tokens
      # @param allowed_placeholders <Array[String]> a list of allowed placeholders
      def initialize(unescapes, tokens, allowed_placeholders)
        raise ArgumentError, "Invalid Parser for String!" unless self.class.applicable?(tokens)

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
