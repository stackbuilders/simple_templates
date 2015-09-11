require_relative '../../test_helper'

describe SimpleTemplates::Parser::Text do
  describe '#parse' do
    let(:delimiter) { SimpleTemplates::Delimiter.new(/\\</, /\\>/, /\</, /\>/) }
    let(:unescapes) { SimpleTemplates::Unescapes.new('<', '>') }
    let(:ast_text) { SimpleTemplates::AST::Text }
    let(:lexer_token) { SimpleTemplates::Lexer::Token }
    let(:target) { SimpleTemplates::Parser::Text }
    let(:valid_phs) { ['name'] }
    let(:ph_tokens) do
      [
        lexer_token.new(:ph_start, '<', 6),
        lexer_token.new(:ph_name, 'name', 7),
        lexer_token.new(:ph_end, '>', 15)
      ]
    end

  describe 'with a valid input' do
      let(:tokens) { [lexer_token.new(:text, 'hello ', 0)].concat(ph_tokens) }

      it 'returns a list with only the text before the placeholder' do
        txt_nodes, _, _ = target.new(unescapes, tokens, valid_phs).parse
        txt_nodes.must_equal [ast_text.new('hello ', 0, true)]
      end

      it 'returns no errors' do
        _, errors_list, _ = target.new(unescapes, tokens, valid_phs).parse
        errors_list.must_be_empty
      end

      it 'returns the remaining tokens containing only the placeholder part' do
        _, _, remaining_tokens = target.new(unescapes, tokens, valid_phs).parse
        remaining_tokens.must_equal ph_tokens
      end
    end

    describe 'with a new line in the placeholder name' do
      let(:other_tokens) do
        [
          lexer_token.new(:ph_start, '<', 6),
          lexer_token.new(:ph_name, 'na', 7),
          lexer_token.new(:text, "\nme", 9),
          lexer_token.new(:ph_end, '>', 12)
        ]
      end
      let(:tokens) { [lexer_token.new(:text, 'hello ', 0)].concat(other_tokens) }

      it 'returns the remainin tokens with a new line as text in the placeholder' do
        _, _, remaining_tokens = target.new(unescapes, tokens, valid_phs).parse
        remaining_tokens.must_equal other_tokens
      end

      it 'returns no errors' do
        _, errors_list, _ = target.new(unescapes, tokens, valid_phs).parse
        errors_list.must_be_empty
      end

      it 'returns the text nodes' do
        txt_nodes, _, _ = target.new(unescapes, tokens, valid_phs).parse
        txt_nodes.must_equal [ast_text.new('hello ', 0, true)]
      end
    end

    describe 'with leading and trailing whitespaces' do
      let(:tokens) { [lexer_token.new(:text, 'hello ', 0)].concat(ph_tokens) }

      it 'returns the remaining tokens with no placeholder name' do
        _, _, remaining_tokens = target.new(unescapes, tokens, valid_phs ).parse
        remaining_tokens.must_equal ph_tokens
      end

      it 'returns the text nodes' do
        txt_nodes, _, _ = target.new(unescapes, tokens, valid_phs ).parse
        txt_nodes.must_equal [ast_text.new('hello ', 0, true)]
      end
    end

    describe 'with a newline after the placeholder' do
      let(:other_tokens) { ph_tokens << lexer_token.new(:text, "\n world", 12) }
      let(:tokens) { [lexer_token.new(:text, 'hello ', 0)].concat(other_tokens) }
      
      it 'returns a list with remaining tokens with the placeholder and followed by text' do
        _, _, remaining_tokens = target.new(unescapes, tokens, valid_phs ).parse
        remaining_tokens.must_equal other_tokens
      end

      it 'returns no errors' do
        _, errors_list, _ = target.new(unescapes, tokens, valid_phs).parse
        errors_list.must_be_empty
      end

      it 'returns the text nodes' do
        txt_nodes, _, _ = target.new(unescapes, tokens, valid_phs ).parse
        txt_nodes.must_equal [ast_text.new('hello ', 0, true)]
      end
    end

    describe 'with a new line character before the placeholder' do
      let(:tokens) { [lexer_token.new(:text, "hello \n", 0)].concat(ph_tokens) }

      it 'returns remaining tokens with the placeholder' do
        _, _, remaining_tokens = target.new(unescapes, tokens, valid_phs ).parse
        remaining_tokens.must_equal ph_tokens
      end

      it 'returns no errors' do
        _, errors_list, _ = target.new(unescapes, tokens, valid_phs).parse
        errors_list.must_be_empty
      end

      it 'returns the text nodes' do
        txt_nodes, _, _ = target.new(unescapes, tokens, valid_phs ).parse
        txt_nodes.must_equal [ast_text.new("hello \n", 0, true)]
      end
    end

    describe 'with a placeholder at the beginning of input' do
      let(:tokens) { ph_tokens << lexer_token.new(:text, ' hello', 6) }

      it 'returns remaining tokens with the placeholder' do
        _, _, remaining_tokens = target.new(unescapes, tokens, valid_phs).parse
        remaining_tokens.must_equal tokens
      end

      it 'returns no errors' do
        _, errors_list, _ = target.new(unescapes, tokens, valid_phs).parse
        errors_list.must_be_empty
      end

      it 'returns nil in the text nodes' do
        txt_nodes, _, _ = target.new(unescapes, tokens, valid_phs).parse
        txt_nodes.must_equal [nil]
      end
    end
  end
end
