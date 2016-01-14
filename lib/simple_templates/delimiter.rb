module SimpleTemplates

  # A +Struct+ for a Delimiter that takes +Regexp+ for the quoted start and
  # quoted end of the placeholder as well as the start and end
  Delimiter = Struct.new(:quoted_ph_start, :quoted_ph_end, :ph_start, :ph_end)
end
