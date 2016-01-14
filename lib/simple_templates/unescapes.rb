module SimpleTemplates
  # A +Struct+ for the unescaped symbols. You want this to mark the placeholder
  # tags. Takes a character for start and another for the end tag
  Unescapes = Struct.new(:start, :end)
end
