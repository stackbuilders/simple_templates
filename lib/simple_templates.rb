require "strscan"

require 'simple_templates/lexer'
require 'simple_templates/placeholder_syntax'
require 'simple_templates/parser'

module SimpleTemplates
  def self.parse(template, whitelisted_placeholders)
    Parser.new(template, whitelisted_placeholders).parse
  end

  def self.render(template, context)
    template.render(context)
  end
end
