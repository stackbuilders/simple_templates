module SimpleTemplates
  class TemplateDeserializer
    def initialize(template)
      @template = template
    end

    def ast
      template['ast'].map do |node|
        Object.const_get(node['class']).new(node['contents'],
                                            node['pos'],
                                            node['allowed'])
      end
    end

    def errors
      template['errors'].map do |error|
        SimpleTemplates::Parser::Error.new(error['message'])
      end
    end

    def remaining_tokens
      template['remaining_tokens'].map do |remaining_token|
        SimpleTemplates::Lexer::Token.new(remaining_token['type'],
                                          remaining_token['content'],
                                          remaining_token['pos'])
      end
    end

    private

    attr_reader :template
  end
end
