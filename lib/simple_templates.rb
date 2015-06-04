require "strscan"

require 'simple_templates/lexer'
require 'simple_templates/parser'

module SimpleTemplates
  def self.render(template, context, placeholder_names)
    Parser.new(template, placeholder_names).parse.map do |node|
      case node
      when String then node
      when Parser::Placeholder then context.public_send(node.name)
      when Parser::Error then raise "Template parsing failed - #{node.message}"
      else raise "Unexpected template node class: #{node.class}!"
      end
    end.join
  end
end
