module SimpleTemplates
  class ParseResult

    attr_reader :template, :errors

    def initialize(template, errors)
      if errors.any? && !template.nil?
        raise ArgumentError,
               "Parse results should not include a Template if parsing failed!"
      end

      @template = template
      @errors   = errors
    end

    def success?
      errors.empty?
    end

    def ==(other)
      template == other.template && errors == other.errors
    end
  end
end
