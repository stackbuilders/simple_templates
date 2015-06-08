require "strscan"

require 'simple_templates/lexer'
require 'simple_templates/template'

require 'simple_templates/parser/base'
require 'simple_templates/parser/result'

require 'simple_templates/parser/error'
require 'simple_templates/parser/placeholder'
require 'simple_templates/parser/template'
require 'simple_templates/parser/text'

require 'simple_templates/AST/node'
require 'simple_templates/AST/text'
require 'simple_templates/AST/placeholder'

module SimpleTemplates
  # Accepts a String representing a template, and an `Array` of placeholders
  # (as `String`s) that should be accepted. Returns a `Parser::Result`.
  def self.parse(raw_template_string, whitelisted_placeholders)
    Parser::Template.new(Lexer.new(raw_template_string).tokenize,
      whitelisted_placeholders).parse
  end
end
