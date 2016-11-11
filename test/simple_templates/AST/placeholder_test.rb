require_relative '../../test_helper'

describe SimpleTemplates::AST::Placeholder do
  let(:target)  {SimpleTemplates::AST::Placeholder}

  describe '#render' do
    let(:substitutions) { { my_placeholder: 'result1' } }

    it 'succeeds' do
      target.new('my_placeholder', 0, true).
        render(substitutions).must_equal("result1")
    end

    it 'fails if the placeholder name is not in the given Hash' do
      -> {
        target.new('not_in_substitutions', 0, true).render(substitutions)
      }.must_raise SimpleTemplates::AST::InterpolationError
    end

    it 'fails if the placeholder is marked as invalid' do
      -> {
        target.new('my_placeholder', 0, false).render(substitutions)
      }.must_raise RuntimeError
    end
  end
end
