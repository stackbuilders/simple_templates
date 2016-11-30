module SimpleTemplates
  class TemplateDeserializer
    def initialize(template)
      @template = template
    end

    def ast
      template['ast'].map do |node|
        klass = node['class']
        if deserializable?(klass)
          ast_class = Object.const_get(klass)
          ast_class.new(node['contents'], node['pos'], node['allowed'])
        else
          raise DeserializationError.new(
            "'#{klass}' is not allowed for deserialization")
        end
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

    def deserializable?(klass)
      %w[
        SimpleTemplates::AST::Placeholder
        SimpleTemplates::AST::Text
      ].include?(klass)
    end
  end

  class DeserializationError < RuntimeError; end
end
