require_relative "test_helper"
require_relative "../lib/simple_templates"
require "ostruct"

describe SimpleTemplates do
  describe "regexps" do
    describe "TEXT_UNTIL_BRACKET" do
      subject { SimpleTemplates::TEXT_UNTIL_BRACKET }

      it "matches empty text" do
        ""[subject].must_equal("")
      end

      it "matches escaped brackets" do
        '\<'[subject].must_equal('\<')
        'Hey \<'[subject].must_equal('Hey \<')
        '\<end'[subject].must_equal('\<end')

        '\>'[subject].must_equal('\>')
        'Hey \>'[subject].must_equal('Hey \>')
        '\>end'[subject].must_equal('\>end')

        '\>\<\<'[subject].must_equal('\>\<\<')
        'H\<\>a\<'[subject].must_equal('H\<\>a\<')
      end

      it "stops when it hits an unescaped bracket" do
        'my name is <name>'[subject].must_equal('my name is <')
        '<placeholder>'[subject].must_equal('<')
        'placeholder> something'[subject].must_equal('placeholder>')
        'hello <'[subject].must_equal('hello <')

        'my name \< is <name>'[subject].must_equal('my name \< is <')
        '\><placeholder>'[subject].must_equal('\><')
        '\<placeholder> something'[subject].must_equal('\<placeholder>')
      end
    end
  end

  describe "parsing" do
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

    it "allows escaped opening and closing brackets" do
      subject = SimpleTemplates.new('<name1>\>\> and 5 \< 10. <name4>')
      subject.tokens.must_equal([[:name, "name1"], [:string, ">> and 5 < 10. "], [:name, "name4"]])
    end

    describe "validations" do
      it "adds an error about an unclosed placeholder" do
        errors = SimpleTemplates.new("<name").errors
        errors.must_equal([SimpleTemplates::ParsingError.new(:unclosed_placeholder, 1, "name")])
        errors.first.message.must_equal('Unclosed placeholder at pos: 1, rest: "name"')
      end

      it "adds an error about unescaped closing bracket" do
        errors = SimpleTemplates.new("<name>>").errors
        errors.must_equal([SimpleTemplates::ParsingError.new(:unescaped_bracket, 7, "")])
        errors.first.message.must_equal('Unescaped bracket at pos: 7, rest: ""')
      end

      it "adds an error if the placeholder name is using something other than word characters" do
        errors = SimpleTemplates.new("<bad placeholder>").errors
        errors.must_equal([SimpleTemplates::ParsingError.new(:misformatted_placeholder, 1, "bad placeholder>")])
        errors.first.message.must_equal('Misformatted placeholder at pos: 1, rest: "bad placeholder>"')
      end
    end
  end

  describe "rendering" do
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
