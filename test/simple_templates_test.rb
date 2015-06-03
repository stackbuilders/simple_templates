require_relative "test_helper"
require_relative "../lib/simple_templates"
require "ostruct"

describe SimpleTemplates do
  it "parses empty template" do
    subject = SimpleTemplates.new("")
    subject.tokens.must_equal([])
  end

  it "parses string template" do
    subject = SimpleTemplates.new("aha")
    subject.tokens.must_equal([[:string, "aha"]])
  end

  it "parses name template" do
    subject = SimpleTemplates.new("<some>")
    subject.tokens.must_equal([[:name, "some"]])
  end

  it "parses mixed template" do
    subject = SimpleTemplates.new("<name1> has <name2> and <name3> has <name4>")
    subject.tokens.must_equal([[:name, "name1"], [:string, " has "], [:name, "name2"], [:string, " and "], [:name, "name3"], [:string, " has "], [:name, "name4"]])
  end

  it "allows multiple start and end marks" do
    subject = SimpleTemplates.new("<name1>>>> and <<<<name4>")
    subject.tokens.must_equal([[:name, "name1"], [:string, ">>> and <<<"], [:name, "name4"]])
  end

  it "fails on missing end mark" do
    err =
    lambda {
      SimpleTemplates.new("<name")
    }.must_raise(SimpleTemplates::UnterminatedString)
    err.pos.must_equal(1)
    err.rest.must_equal("name")
  end

  describe "#render" do
    subject { SimpleTemplates.new("<first_name> is cool") }

    it "resolves all variables" do
      context = OpenStruct.new(first_name: "Tom")
      subject.render(context).must_equal("Tom is cool")
    end

    it "raises error if variable is missing from the context" do
      error =
      lambda {
        subject.render(Object.new)
      }.must_raise(NoMethodError)
      error.name.must_equal(:first_name)
    end
  end

end
