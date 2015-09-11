require_relative '../../test_helper'

describe SimpleTemplates::Parser::Text do
  describe '#parse' do
    let(:delimiter) { SimpleTemplates::Delimiter.new(/\\</, /\\>/, /\</, /\>/) }
    let(:unescapes) { SimpleTemplates::Unescapes.new('<', '>') }
    let(:target) { SimpleTemplates::Parser::Placeholder }
    let(:ast_ph) { SimpleTemplates::AST::Placeholder }
    let(:lexer_token) { SimpleTemplates::Lexer::Token }
    let(:parse_error) { SimpleTemplates::Parser::Error }
    let(:valid_phs) { ['name'] }
    let (:ph_tokens) do
      [
        lexer_token.new(:ph_start, '<', 0),
        lexer_token.new(:ph_name, 'name', 1),
        lexer_token.new(:ph_end, '>', 9),
      ]
    end

    describe 'with a placeholder as the first part of the input' do
      let(:tokens) { ph_tokens << lexer_token.new(:text, ' some text', 10) }

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
        placeholder_ast.must_equal [ast_ph.new('name', 0, true)]
      end
    end

    describe 'with no placeholder as the first part of the input' do
      let(:tokens) { ph_tokens.unshift(lexer_token.new(:text, 'hello ', 0)) }

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
      let(:tokens) do
        [
          lexer_token.new(:ph_start, '<', 0),
          lexer_token.new(:ph_end, '>', 1),
          lexer_token.new(:text,  ' some text', 2)
        ]
      end 

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
      let(:tokens) do
        [
          lexer_token.new(:ph_start, '<', 0),
          lexer_token.new(:ph_name, 'name', 1),
          lexer_token.new(:text, '-', 5),
          lexer_token.new(:ph_end, '>', 6),
          lexer_token.new(:text, ' some text', 7),
        ]
      end
 
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
      let(:tokens) do
        [
          lexer_token.new(:ph_end, '>', 0),
          lexer_token.new(:text, ' some text', 1),
        ]
      end

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
