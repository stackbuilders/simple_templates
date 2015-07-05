require_relative "../../test_helper"

module SimpleTemplates
  class Parser
    class TestNodeParserImpl < NodeParser
      STARTING_TOKENS = ["text"]
    end
  end
end

describe SimpleTemplates::Parser::NodeParser do
  let(:target)  {SimpleTemplates::Parser::NodeParser}
  let(:impl)    {SimpleTemplates::Parser::TestNodeParserImpl}
  let(:example) {SimpleTemplates::AST::Text.new("a", 0, true)}

  describe "#applicable?" do
    it "ignores missing" do
      impl.applicable?([]).must_equal false
    end
    it "can be applied" do
      impl.applicable?([example]).must_equal true
    end
    it "can't be applied" do
      target.applicable?([example]).must_equal false
    end
  end

end
