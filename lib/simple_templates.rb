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

  attr_reader :compiled, :template

  def initialize(template)
    @template = template
    tokenize!
  end

  def tokenize!
    return @compiled if @compiled
    @compiled = []
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
        @compiled << [:string, string] unless string.empty?
        started = true
      when end___tag_reg
        @compiled << [:name, string.to_sym] unless string.empty?
        started = false
      when text__tag_reg
        @compiled << [:string, match] unless match.empty?
      else
        raise UnterminatedString.new scanner.pos, scanner.rest
      end
    end
    @compiled
  end

  def result(object)
    compiled.map do |type, value|
      case type
      when :string then value
      when :name   then object.public_send(value)
      end
    end.join("")
  end

end
