require_relative "../../test_helper"

describe SimpleTemplates::AST::Placeholder do
  let(:target)  {SimpleTemplates::AST::Placeholder}

  describe "render" do
    let(:valid)   {target.new("a", 0, true)}
    let(:missing) {target.new("b", 0, true)}
    let(:context) {Struct.new(:a).new("result1")}

    it "fails" do
      ->(){
        missing.render(context)
      }.must_raise NoMethodError
    end

    it "succeeds" do
      valid.render(context).must_equal("result1")
    end
  end

end
