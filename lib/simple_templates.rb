require "strscan"

require 'simple_templates/lexer'
require 'simple_templates/placeholder_syntax'
require 'simple_templates/parser'

module SimpleTemplates
  def self.render(template, context, whitelisted_placeholders)
    nodes = Parser.new(template, whitelisted_placeholders).parse

    if (nodes.any? && nodes.first.is_a?(Parser::Error))
      nodes
    else
      nodes.map do |node|
        case node
        when String then node
        when Parser::Placeholder then context.public_send(node.name)
        else
          raise "Probable bug in Parser, please report: found unexpected node class '#{node.class}'!"
        end
      end.join
    end

  end
end
