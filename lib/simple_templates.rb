require "strscan"

class SimpleTemplates

  class UnterminatedString < StandardError
    attr_reader :pos, :rest
    def initialize(pos, rest)
      @pos  = pos
      @rest = rest
      super("Unterminated string(at: #{pos}): #{rest}")
    end
  end

  attr_reader :template, :tokens

  def initialize(template)
    @template = template
    tokenize!
  end

  def tokenize!
    @tokens = []
    text__tag_reg = /(.*?)(<|\z)+/m
    start_tag_reg = /(.*?)(<)+/m
    end___tag_reg = /(.*?)>/m
    started = false
    scanner = StringScanner.new(template)
    until scanner.eos?
      match  = scanner.scan(started ? end___tag_reg : text__tag_reg)
      string = match && match[0..-2]
      case match
      when start_tag_reg
        @tokens << [:string, string] unless string.empty?
        started = true
      when end___tag_reg
        @tokens << [:name, string] unless string.empty?
        started = false
      when text__tag_reg
        @tokens << [:string, match] unless match.empty?
      else
        raise UnterminatedString.new scanner.pos, scanner.rest
      end
    end
    @tokens
  end

  def render(context)
    tokens.map do |type, value|
      case type
      when :string then value
      when :name   then context.public_send(value)
      end
    end.join
  end

end
