require "strscan"

class SimpleTemplates
  ERROR_MESSAGES = {
    unclosed_placeholder: "Unclosed placeholder",
    unescaped_bracket: "Unescaped bracket",
    misformatted_placeholder: "Misformatted placeholder"
  }

  ParsingError = Struct.new(:error_code, :pos, :rest) do
    def message
      %(#{ERROR_MESSAGES.fetch(error_code)} at pos: #{pos}, rest: "#{rest[0..15]}")
    end
  end

  TEXT_UNTIL_BRACKET = /(\\<|\\>|[^<>])*(<|>|\z)/
  TEXT_UNTIL_END_BRACKET = /(\\<|\\>|[^<>])*(>|\z)/

  attr_reader :template, :tokens, :errors

  def initialize(template)
    @template = template
    tokenize!
  end

  def tokenize!
    @tokens = []
    @errors = []

    scanner = StringScanner.new(template)
    until scanner.eos?
      match = scanner.scan(TEXT_UNTIL_BRACKET)
      if match.end_with?('<')
        text = match[0..-2]
        @tokens << [:string, unescape(text)] unless text.empty?

        scan_placeholder(scanner)
      elsif match.end_with?('>')
        @errors << ParsingError.new(:unescaped_bracket, scanner.pos, scanner.rest)
      else
        @tokens << [:string, unescape(match)] unless match.empty?
      end
    end
  end

  def render(context)
    tokens.map do |type, value|
      case type
      when :string then value
      when :name   then context.public_send(value)
      end
    end.join
  end

  private

  def unescape(text)
    text.gsub('\<', '<').gsub('\>', '>')
  end

  def scan_placeholder(scanner)
    starting_position = scanner.pos
    starting_remainder = scanner.rest

    placeholder_name = scanner.scan(TEXT_UNTIL_END_BRACKET)
    case placeholder_name
    when /\A\w+>\z/
      @tokens << [:name, placeholder_name[0..-2]]
    when /\A[^\\]*>\z/
      @errors << ParsingError.new(:misformatted_placeholder, starting_position, starting_remainder)
    else
      @errors << ParsingError.new(:unclosed_placeholder, starting_position, starting_remainder)
    end
  end
end
