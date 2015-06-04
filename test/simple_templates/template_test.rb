require_relative "../test_helper"

require 'set'

describe SimpleTemplates::Template do
  describe "#placeholder_names" do
    it "should return a set of the placeholder names in the template" do
      SimpleTemplates::Parser.new('foo <bar> <baz>', ['bar', 'baz']).parse.placeholder_names.must_equal ['bar', 'baz'].to_set
    end
  end
end
