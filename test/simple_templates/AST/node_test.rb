require_relative "../../test_helper"

module SimpleTemplates
  module AST
    class TestNodeImpl < Node
      def render(context)
      end
    end
  end
end

describe SimpleTemplates::AST::Node do
  let(:target)   {SimpleTemplates::AST::Node}
  let(:allowed)  {target.new("a", 0, true)}
  let(:impl)     {SimpleTemplates::AST::TestNodeImpl.new("a", 0, true)}

  describe "==" do
    it "is equal" do
      allowed.must_equal target.new("a", 0, true)
    end
    it "isn't equal" do
      allowed.wont_equal target.new("b", 0, true)
      allowed.wont_equal target.new("a", 1, true)
      allowed.wont_equal target.new("a", 0, false)
      allowed.wont_equal target.new("b", 1, false)
    end
  end

  describe "allowed?" do
    it "is allowed?" do
      allowed.allowed?.must_equal true
    end
    it "isn't allowed?" do
      target.new("a", 0, false).allowed?.must_equal false
    end
  end

  describe "render" do
    let(:context) { {a: 1} }
    it "fails" do
      ->(){
        allowed.render(context)
      }.must_raise NotImplementedError
    end
    it "succeeds" do
      impl.render(context).must_be_nil
    end
  end

end
