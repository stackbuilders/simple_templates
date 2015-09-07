module SimpleTemplates
  Delimiter = Struct.new(
    :quoted_ph_start,
    :quoted_ph_end,
    :ph_start,
    :ph_end
  )
end
