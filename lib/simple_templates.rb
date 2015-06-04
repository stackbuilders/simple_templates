require "strscan"

require 'simple_templates/lexer'
require 'simple_templates/parser'

module SimpleTemplates
  def self.render(template, context, placeholder_names)
    nodes = Parser.new(template, placeholder_names).parse
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
