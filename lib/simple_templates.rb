require "strscan"

require 'simple_templates/lexer'
require 'simple_templates/parser/template'

module SimpleTemplates
  # Accepts a String representing a template, and an `Array` of placeholders
  # (as `String`s) that should be accepted. Returns a `Parser::Result`.
  def self.parse(raw_template_string, whitelisted_placeholders)
    Parser::Template.new(Lexer.new(raw_template_string).tokenize,
      whitelisted_placeholders).parse
  end
end
