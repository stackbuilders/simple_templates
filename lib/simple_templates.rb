require "strscan"

require 'simple_templates/lexer'
require 'simple_templates/placeholder_parser'
require 'simple_templates/AST/node'
require 'simple_templates/AST/text'
require 'simple_templates/AST/placeholder'
require 'simple_templates/parser'

module SimpleTemplates
  # Accepts a String representing a template, and an `Array` of placeholders
  # (as `String`s) that should be accepted. Returns a `ParseResult`.
  def self.parse(raw_template_string, whitelisted_placeholders)
    Parser.new(raw_template_string, whitelisted_placeholders).parse
  end

  # Accepts a renderable `Template`, and a context in which it should be
  # rendered. Substitutes `Placeholder`s with the result of calling methods
  # with the same name on the context `Object`.
  def self.render(template, context)
    template.render(context)
  end
end
