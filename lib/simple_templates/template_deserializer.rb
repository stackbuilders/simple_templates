module SimpleTemplates
  class TemplateDeserializer
    def initialize(template)
      @template = template
    end

    def ast
      nodes = []
      template['ast'].each do |node|
        klass = node['class']
        if valid_ast_class?(klass)
          ast_class = Object.const_get(klass)
          nodes << ast_class.new(node['contents'],
                                 node['pos'],
                                 node['allowed'])
        else
          raise InvalidClassForDeserializationError.new(
            "'#{klass}' is not allowed for deserialization")
        end
      end

      nodes
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

    def valid_ast_class?(ast_class)
      [
        "SimpleTemplates::AST::Placeholder",
        "SimpleTemplates::AST::Text",
      ].include?(ast_class)
    end
  end

  class InvalidClassForDeserializationError < RuntimeError; end
end
