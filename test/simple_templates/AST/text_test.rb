require_relative "../../test_helper"

describe SimpleTemplates::AST::Text do
  let(:target)  {SimpleTemplates::AST::Text}
  let(:valid)   {target.new("a", 0, true)}
  let(:context) {Struct.new(:a).new("result1")}

  describe "render" do
    it "succeeds" do
      valid.render(context).must_equal("a")
    end
  end

  describe "+" do
    it "adds valid" do
      valid.+(target.new("b", 1, true)).must_equal target.new("ab", 0, true)
    end
    it "adds invalid" do
      valid.+(target.new("b", 1, false)).must_equal target.new("ab", 0, false)
    end
  end

end
