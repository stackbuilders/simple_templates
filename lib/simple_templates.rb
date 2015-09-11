require 'simple_templates/template'
require 'simple_templates/lexer'
require 'simple_templates/parser'
require 'simple_templates/unescapes'
require 'simple_templates/delimiter'

# A minimalistic templates engine
module SimpleTemplates
  #
  # Builds a template renderer from given string template and list of
  # allowed placeholders
  #
  # @param raw_template_string      String        the template to render
  # @param allowed_placeholders Array[String] list of allowed placeholders
  # @return [<SimpleTemplates::Template>]
  #   A template cointaining a list of ASTs, errors and unparsed tokens
  #
  # @example template without errors
  #   template = SimpleTemplates.parse("Hi <name>", %w[name])
  #   template.render({ name: "Bob" }) if template.errors.empty?
  #   => "Hi Bob"
  #
  # @example template with errors
  #   template = SimpleTemplates.parse("Hi <name>", %w[date])
  #   template.errors
  #   => [...] # unknown placeholder
  #
  def self.parse(raw_template_string, allowed_placeholders = nil)
    Template.new(
      *Parser.new(
        Unescapes.new('<', '>'),
        Lexer.new(Delimiter.new(/\\</, /\\>/, /\</, /\>/), raw_template_string).
          tokenize,
        allowed_placeholders
      ).parse
    )
  end
end
