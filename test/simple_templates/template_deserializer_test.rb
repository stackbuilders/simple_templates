require_relative "../test_helper"

describe SimpleTemplates::TemplateDeserializer do
  before do
    @serialized_template = JSON.parse(
      SimpleTemplates.parse('Hi <name>', %w[date]).to_h.to_json)
  end

  let(:template) do
    SimpleTemplates::TemplateDeserializer.new(@serialized_template)
  end

  describe "#ast" do
    it 'creates an array of AST nodes' do
      template.ast.map(&:class).must_equal [
        SimpleTemplates::AST::Text,
        SimpleTemplates::AST::Placeholder
      ]

      template.ast.map(&:contents).must_equal ["Hi ", "name"]
    end

    it 'raises an error if any class contains an unexpected string' do
      harmful_serialized_template = {
        "ast" => [
          { "class" => "SimpleTemplates::AST::Placeholder" },
          { "class" => "harmful code" },
        ],
        "errors" => [],
        "remaining_tokens" => []
      }

      bad_template = SimpleTemplates::TemplateDeserializer.new(
        harmful_serialized_template)

      -> {
        bad_template.ast
      }.must_raise SimpleTemplates::InvalidClassForDeserializationError
    end
  end

  describe "#errors" do
    it 'creates an array of errors' do
      template.errors.map(&:class).must_equal [
        SimpleTemplates::Parser::Error
      ]

      template.errors.map(&:message).must_equal [
        "Invalid Placeholder with contents, 'name' found starting at position 3."
      ]
    end
  end

  describe "#remaining_tokens" do
    it 'creates an array of remaining tokens'
  end
end
