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
  let(:target) {SimpleTemplates::AST::Node}
  let(:valid)  {target.new("a", 0, true)}
  let(:impl)   {SimpleTemplates::AST::TestNodeImpl.new("a", 0, true)}

  describe "==" do
    it "is equal" do
      valid.must_equal target.new("a", 0, true)
    end
    it "isn't equal" do
      valid.wont_equal target.new("b", 0, true)
      valid.wont_equal target.new("a", 1, true)
      valid.wont_equal target.new("a", 0, false)
      valid.wont_equal target.new("b", 1, false)
    end
  end

  describe "valid?" do
    it "is valid?" do
      valid.valid?.must_equal true
    end
    it "isn't valid?" do
      target.new("a", 0, false).valid?.must_equal false
    end
  end

  describe "render" do
    let(:context) {OpenStruct.new(:a=>1)}
    it "fails" do
      ->(){
        valid.render(context)
      }.must_raise NotImplementedError
    end
    it "succeeds" do
      impl.render(context)
    end
  end

end
