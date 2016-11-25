require_relative "../test_helper"

describe SimpleTemplates::TemplateDeserializer do
  before do
    @serialized_template = JSON.parse(
      SimpleTemplates.parse('Hi <name>', %w[date]).to_h.to_json)
  end

  let(:template) { SimpleTemplates::TemplateDeserializer.new(@serialized_template) }

  describe "#ast" do
    it 'creates an array of text or placeholders' do
      template.ast.map(&:class).must_equal [
        SimpleTemplates::AST::Text,
        SimpleTemplates::AST::Placeholder
      ]

      template.ast.map(&:contents).must_equal ["Hi ", "name"]
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
