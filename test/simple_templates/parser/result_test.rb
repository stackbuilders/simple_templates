require_relative "../../test_helper"

describe SimpleTemplates::Parser::Result do
  describe "#initialize" do
    it "assigns to template if there are no errors" do
      SimpleTemplates::Parser::Result.new(:template, [], []).template.must_equal :template
    end

    it "assigns `nil` to the template if there are errors" do
      SimpleTemplates::Parser::Result.new(:template, [:an_error], []).template.must_be_nil
    end
  end

  describe "#success?" do
    it "returns true if there are no errors" do
      SimpleTemplates::Parser::Result.new(:template, [], []).success?.must_equal true
    end

    it "returns false if there are errors" do
      SimpleTemplates::Parser::Result.new(:template, [:an_error], []).success?.must_equal false
    end
  end
end
