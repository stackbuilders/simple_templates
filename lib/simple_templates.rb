require "strscan"

class SimpleTemplates
  ERROR_MESSAGES = {
    unclosed_placeholder: "Unclosed placeholder",
    unescaped_bracket: "Unescaped bracket",
    misformatted_placeholder: "Misformatted placeholder",
    invalid_placeholder: "Invalid placeholder is used"
  }

  ParsingError = Struct.new(:error_code, :pos, :rest) do
    def message
      %(#{ERROR_MESSAGES.fetch(error_code)} at pos: #{pos}, rest: "#{rest[0..15]}")
    end
  end

  TEXT_UNTIL_BRACKET = /(\\<|\\>|[^<>])*(<|>|\z)/
  TEXT_UNTIL_END_BRACKET = /(\\<|\\>|[^<>])*(>|\z)/

  attr_reader :template, :tokens, :errors, :allowed_placeholders

  def initialize(template, allowed_placeholders=nil)
    @template = template
    @allowed_placeholders = allowed_placeholders
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

  def names
    tokens.select { |type, _| type == :name }.map { |_, value| value }.uniq
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
      placeholder_name = placeholder_name[0..-2]

      @tokens << [:name, placeholder_name]
      if allowed_placeholders && !allowed_placeholders.include?(placeholder_name)
        @errors << ParsingError.new(:invalid_placeholder, starting_position, starting_remainder)
      end
    when /\A[^\\]*>\z/
      @errors << ParsingError.new(:misformatted_placeholder, starting_position, starting_remainder)
    else
      @errors << ParsingError.new(:unclosed_placeholder, starting_position, starting_remainder)
    end
  end
end
