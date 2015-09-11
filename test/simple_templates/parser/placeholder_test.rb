require_relative '../../test_helper'

describe SimpleTemplates::Parser::Text do
  describe '#parse' do
    let(:delimiter) { SimpleTemplates::Delimiter.new(/\\</, /\\>/, /\</, /\>/) }
    let(:unescapes) { SimpleTemplates::Unescapes.new('<', '>') }
    let(:target) { SimpleTemplates::Parser::Placeholder }
    let(:ast_ph) { SimpleTemplates::AST::Placeholder }
    let(:lexer) { SimpleTemplates::Lexer }
    let(:lexer_token) { SimpleTemplates::Lexer::Token }
    let(:parse_error) { SimpleTemplates::Parser::Error }


    describe 'with a placeholder as the first part of the input' do
      let(:raw_input) { "<1_name_1> some text" }
      let(:tokens) { lexer.new(delimiter, raw_input).tokenize }
      let(:valid_phs) { ['1_name_1'] }

      it 'returns no errors' do
        _, errors, _ = target.new(unescapes, tokens, valid_phs).parse
        errors.must_be_empty
      end

      it 'returns the remaining tokens after the placeholder' do
        _, _, remaining_tokens = target.new(unescapes, tokens, valid_phs).parse

        remaining_tokens.must_equal [lexer_token.new(:text, ' some text', 10)]
      end

      it 'returns a AST placeholder' do
        placeholder_ast, _, _ = target.new(unescapes, tokens, valid_phs).parse

        placeholder_ast.must_equal [ast_ph.new('1_name_1', 0, true)]
      end
    end

    describe 'with no placeholder as the first part of the input' do
      let(:raw_input) { "hello <1_name_1>" }
      let(:tokens) { lexer.new(delimiter, raw_input).tokenize }
      let(:valid_phs) { ['1_name_1'] }

      it 'returns an error about not finding the placeholder' do
        _, errors, _ = target.new(unescapes, tokens, valid_phs).parse
        errors.must_equal [
          parse_error.new('Expected placeholder start token at character position 0, but found a text token instead.')
        ]
      end

      it 'returns nil as the remaining tokens' do
        _, _, remaining_tokens = target.new(unescapes, tokens, valid_phs).parse
        remaining_tokens.must_be_nil
      end

      it 'returns an empty list of AST placeholders' do
        placeholder_ast, _, _ = target.new(unescapes, tokens, valid_phs).parse
        placeholder_ast.must_be_empty
      end
    end

    describe 'with an empty placeholder' do
      let(:raw_input) { "<> some text" }
      let(:tokens) { lexer.new(delimiter, raw_input).tokenize }
      let(:valid_phs) { ['1_name_1'] }

      it 'returns an error about not finding the placeholder' do
        _, errors, _ = target.new(unescapes, tokens, valid_phs).parse
        errors.must_equal [
          parse_error.new('Expected placeholder name token at character position 1, but found a placeholder end token instead.')
        ]
      end

      it 'returns nil as the remaining tokens' do
        _, _, remaining_tokens = target.new(unescapes, tokens, valid_phs).parse
        remaining_tokens.must_be_nil
      end

      it 'returns an empty list of AST placeholders' do
        placeholder_ast, _, _ = target.new(unescapes, tokens, valid_phs).parse
        placeholder_ast.must_be_empty
      end
    end

    describe 'with an invalid placeholder name' do
      let(:raw_input) { "<name-> some text" }
      let(:tokens) { lexer.new(delimiter, raw_input).tokenize }
      let(:valid_phs) { ['name'] }

      it 'returns an error about not finding the placeholder' do
        _, errors, _ = target.new(unescapes, tokens, valid_phs).parse
        errors.must_equal [
          parse_error.new('Expected placeholder end token at character position 5, but found a text token instead.')
        ]
      end

      it 'returns nil as the remaining tokens' do
        _, _, remaining_tokens = target.new(unescapes, tokens, valid_phs).parse
        remaining_tokens.must_be_nil
      end

      it 'returns an empty list of AST placeholders' do
        placeholder_ast, _, _ = target.new(unescapes, tokens, valid_phs).parse
        placeholder_ast.must_be_empty
      end
    end

    describe 'with a placeholder end as the first part of the input' do
      let(:raw_input) { "> some text" }
      let(:tokens) { lexer.new(delimiter, raw_input).tokenize }
      let(:valid_phs) { ['name'] }

      it 'returns an error about not finding the placeholder' do
        _, errors, _ = target.new(unescapes, tokens, valid_phs).parse
        errors.must_equal [
          parse_error.new('Expected placeholder start token at character position 0, but found a placeholder end token instead.')
        ]
      end

      it 'returns nil as the remaining tokens' do
        _, _, remaining_tokens = target.new(unescapes, tokens, valid_phs).parse
        remaining_tokens.must_be_nil
      end

      it 'returns an empty list of AST placeholers' do
        placeholder_ast, _, _ = target.new(unescapes, tokens, valid_phs).parse
        placeholder_ast.must_be_empty
      end
    end
  end
end
