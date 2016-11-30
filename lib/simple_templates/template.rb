require 'set'

require 'simple_templates/AST/placeholder'
require 'simple_templates/template_deserializer'

module SimpleTemplates
  #
  # A +Template+ is a renderable collection of SimpleTemplates::AST nodes.
  #
  # @!attribute [r] ast
  #   @return <Array[SimpleTemplates::AST::Node]> a list of renderable nodes
  # @!attribute [r] errors
  #   @return <Array[SimpleTemplates::Parser::Error]> a list of errors found
  #     during parsing
  # @!attribute [r] remaining_tokens
  #   @return <Array[SimpleTemplates::Lexer::Token]> a list of the remaining
  #     not parsed tokens
  #
  class Template

    attr_reader :ast, :errors, :remaining_tokens

    # Creates a new Template from a JSON string
    # @return [SimpleTemplates::Template]
    def self.from_json(json)
      deserialized_template = SimpleTemplates::TemplateDeserializer.new(JSON.parse(json))
      new(deserialized_template.ast,
          deserialized_template.errors,
          deserialized_template.remaining_tokens)
    end

    # Initializes a new Template
    # @param ast <Array[SimpleTemplates::AST::Node]> list of AST nodes
    # @param errors <Array[SimpleTemplates::Parser::Error]> a list of errors
    #   found during parsing
    # @param remaining_tokens <Array[SimpleTemplates::Lexer::Token]> list of
    #   unparsed tokens from the input
    def initialize(ast = [], errors = [], remaining_tokens = [])
      @ast              = ast.clone.freeze
      @errors           = errors.clone.freeze
      @remaining_tokens = remaining_tokens.clone.freeze
    end

    # Returns all placeholder names used in the template.
    # @return [Set<String>] Placeholders content
    def placeholder_names
      placeholders.map(&:contents).to_set
    end

    # Accepts a hash with the placeholder names as keys and the values for
    # substitution
    # @param substitutions [Hash{Symbol => String}] a hash with the placeholder
    #   name as the key and the substitution for that placeholder as value
    # @return [String] The concatenated result of rendering the substitutions
    def render(substitutions)
      raise errors.map(&:message).join(", ") unless errors.empty?
      ast.map { |node| node.render(substitutions) }.join
    end

    # Returns all the +SimpleTemplates::AST::Placeholder+ nodes in the +ast+
    #   list of the instance
    # @return [Set<SimpleTemplates::AST::Placeholder>]
    def placeholders
      ast.select{ |node| SimpleTemplates::AST::Placeholder === node }.to_set
    end

    # Converts a +SimpleTemplates::Template+ to Hash.
    # return [Hash]
    def to_h
      {
        ast: ast.map(&:to_h),
        errors: errors.map(&:to_h),
        remaining_tokens: remaining_tokens.map(&:to_h)
      }
    end

    # Compares a +Template+ with another by comparing the +ast+, +errors+
    # and the +remaining_tokens+ of each one
    def ==(other)
      ast == other.ast &&
        errors == other.errors &&
        remaining_tokens == other.remaining_tokens
    end
  end
end
