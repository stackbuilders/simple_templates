require "strscan"

require 'simple_templates/lexer'
require 'simple_templates/parser'

module SimpleTemplates
  #
  # Builds a template renderer from given string template and list of
  # allowed placeholders
  #
  # @param raw_template_string      String        the template to render
  # @param whitelisted_placeholders Array[String] list of allowed placeholders
  # @returns Array[SimpleTemplates::Template, Array, Array]
  #   template, array of errors, array of remaining tokens if error
  #
  # @example template without errors
  #   template, errors, unparsed = SimpleTemplates.parse("Hi <name>", %w[name])
  #   template.render("Bob") if errors.empty?
  #   => "Hi Bob"
  #
  # @example template with errors
  #   template, errors, unparsed = SimpleTemplates.parse("Hi <name>", %w[date])
  #   template
  #   => nil
  #   errors
  #   => [...] # unknown placeholder
  #
  def self.parse(raw_template_string, whitelisted_placeholders)
    ast, errors, remaining_tokens =
    Template.new(
      *Parser.new(
        Lexer.new(raw_template_string).tokenize,
        whitelisted_placeholders
      ).parse
    )
  end
end
