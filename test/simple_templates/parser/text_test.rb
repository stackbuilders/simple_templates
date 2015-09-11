require_relative '../../test_helper'

describe SimpleTemplates::Parser::Text do
  describe '#parse' do
    let(:delimiter) { SimpleTemplates::Delimiter.new(/\\</, /\\>/, /\</, /\>/) }
    let(:unescapes) { SimpleTemplates::Unescapes.new('<', '>') }
    let(:target) { SimpleTemplates::Parser::Text }
    let(:ast_text) { SimpleTemplates::AST::Text }
    let(:lexer) { SimpleTemplates::Lexer }
    let(:lexer_token) { SimpleTemplates::Lexer::Token }

    it 'returns an empty list of errors no matter the input' do
      inputs = ["\nhello<name>", "hello <name>", "<name> hello"]
      tokens = inputs.collect { |x| lexer.new(delimiter, x).tokenize }
      results = tokens.collect { |x| target.new(unescapes, x, ['name']).parse }
      errors = results.collect { |x| x[1] }.flatten
      errors.must_be_empty
    end

    it 'returns a list of SimpleTemplates::AST::Text elements' do
      raw_input = "hello <name>"
      tokens_ = lexer.new(delimiter, raw_input).tokenize
      txt_nodes, _, _ = target.new(unescapes, tokens_, ['name']).parse
      txt_nodes.must_be_instance_of Array
      txt_nodes.first.must_be_instance_of SimpleTemplates::AST::Text
    end

    it 'returns list of remaing tokens from the lexer as last element' do
      raw_input = "hello <name>"
      tokens_ = lexer.new(delimiter, raw_input).tokenize
      _, _, remaining_tokens = target.new(unescapes, tokens_, ['name']).parse
      remaining_tokens.must_be_instance_of Array
      remaining_tokens.each { |x| x.must_be_instance_of lexer::Token }
    end

   describe 'with a valid input' do
      let(:raw_input) { "hello <1_name_1>" }
      let(:tokens) { lexer.new(delimiter, raw_input).tokenize }
      let(:valid_phs) { ['1_name_1'] }

      it 'returns a list with only the text before the placeholder' do
        txt_nodes, _, _ = target.new(unescapes, tokens, valid_phs).parse
        txt_nodes.must_equal [ast_text.new('hello ', 0, true)]
      end

      it 'returns the remaining tokens containing only the placeholder part' do
        _, _, remaining_tokens = target.new(unescapes, tokens, valid_phs).parse

        remaining_tokens.must_equal [
          lexer_token.new(:ph_start, '<', 6),
          lexer_token.new(:ph_name, '1_name_1', 7),
          lexer_token.new(:ph_end, '>', 15)
        ]
      end
    end

    describe 'with a new line in the placeholder name' do
      let(:raw_input) { "hello <na\nme>" }
      let(:tokens) { lexer.new(delimiter, raw_input).tokenize }
      let(:valid_phs) { ['name'] }

      it 'returns the remainin tokens with a new line as text in the placeholder' do
        _, _, remaining_tokens = target.new(unescapes, tokens, valid_phs).parse

        remaining_tokens.must_equal [
          lexer_token.new(:ph_start, '<', 6),
          lexer_token.new(:ph_name, 'na', 7),
          lexer_token.new(:text, "\nme", 9),
          lexer_token.new(:ph_end, '>', 12)
        ]
      end

      it 'returns the text nodes' do
        txt_nodes, _, _ = target.new(unescapes, tokens, valid_phs).parse
        txt_nodes.must_equal [ast_text.new('hello ', 0, true)]
      end
    end

    describe 'with leading and trailing whitespaces' do
      let(:raw_input) { "hello < name >" }
      let(:tokens) { lexer.new(delimiter, raw_input).tokenize }
      let(:valid_phs) { ['name'] }

      it 'returns the remaining tokens with no placeholder name' do
        _, _, remaining_tokens = target.new(unescapes, tokens, valid_phs ).parse

        remaining_tokens.must_equal [
          lexer_token.new(:ph_start, '<', 6),
          lexer_token.new(:text, ' name ', 7),
          lexer_token.new(:ph_end, '>', 13)
        ]
      end

      it 'returns the text nodes' do
        txt_nodes, _, _ = target.new(unescapes, tokens, valid_phs ).parse
        txt_nodes.must_equal [ast_text.new('hello ', 0, true)]
      end
    end

    describe 'with a newline after the placeholder' do
      let(:raw_input) { "hello <name>\n world" }
      let(:tokens) { lexer.new(delimiter, raw_input).tokenize }
      let(:valid_phs) { ['name'] }

      it 'returns a list with remaining tokens with the placeholder and followed by text' do
        _, _, remaining_tokens = target.new(unescapes, tokens, valid_phs ).parse

        remaining_tokens.must_equal [
          lexer_token.new(:ph_start, '<', 6),
          lexer_token.new(:ph_name, 'name', 7),
          lexer_token.new(:ph_end, '>', 11),
          lexer_token.new(:text, "\n world", 12)
        ]
      end

      it 'returns the text nodes' do
        txt_nodes, _, _ = target.new(unescapes, tokens, valid_phs ).parse
        txt_nodes.must_equal [ast_text.new('hello ', 0, true)]
      end
    end

    describe 'with a new line character before the placeholder' do
      let(:raw_input) { "hello \n<name>" }
      let(:tokens) { lexer.new(delimiter, raw_input).tokenize }
      let(:valid_phs) { ['name'] }

      it 'returns remaining tokens with the placeholder' do
        _, _, remaining_tokens = target.new(unescapes, tokens, valid_phs ).parse

        remaining_tokens.must_equal [
          lexer_token.new(:ph_start, '<', 7),
          lexer_token.new(:ph_name, 'name', 8),
          lexer_token.new(:ph_end, '>', 12)
        ]
      end

      it 'returns the text nodes' do
        txt_nodes, _, _ = target.new(unescapes, tokens, valid_phs ).parse
        txt_nodes.must_equal [ast_text.new("hello \n", 0, true)]
      end
    end

    describe 'with a placeholder at the beginning of input' do
      let(:raw_input) { "<name> hello" }
      let(:tokens) { lexer.new(delimiter, raw_input).tokenize }
      let(:valid_phs) { ['name'] }

      it 'returns remaining tokens with the placeholder' do
        _, _, remaining_tokens = target.new(unescapes, tokens, valid_phs).parse

        remaining_tokens.must_equal [
          lexer_token.new(:ph_start, '<', 0),
          lexer_token.new(:ph_name, 'name', 1),
          lexer_token.new(:ph_end, '>', 5),
          lexer_token.new(:text, ' hello', 6)
        ]
      end

      it 'returns nil in the text nodes' do
        txt_nodes, _, _ = target.new(unescapes, tokens, valid_phs).parse
        txt_nodes.must_equal [nil]
      end
    end
  end
end
