module SimpleTemplates
  class ParseResult

    attr_reader :template, :errors

    def initialize(template, errors)
      @errors   = errors
      @template = success? ? template : nil
    end

    def success?
      errors.empty?
    end

    def ==(other)
      template == other.template && errors == other.errors
    end
  end
end
