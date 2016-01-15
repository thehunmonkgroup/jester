local conf = {
  action_map = {

    -- Alias for format_string, to maintain backwards compat.
    format_number = {
      mod = "format",
      func = "format_string",
    },

    format_string = {
      mod = "format",
      func = "format_string",
    },

    format_date = {
      mod = "format",
      func = "format_date",
    },

  }
}

return conf
