local conf = {
  action_map = {

    -- Alias for navigation_add, to maintain backwards compat.
    add_to_stack = {
      mod = "navigation",
      func = "navigation_add",
    },

    navigation_add = {
      mod = "navigation",
      func = "navigation_add",
    },

    -- Alias for navigation_previous, to maintain backwards compat.
    navigation_up = {
      mod = "navigation",
      func = "navigation_previous",
    },

    navigation_previous = {
      mod = "navigation",
      func = "navigation_previous",
    },

    navigation_clear = {
      mod = "navigation",
      func = "navigation_clear",
    },

    -- Alias for navigation_beginning, to maintain backwards compat.
    navigation_top = {
      mod = "navigation",
      func = "navigation_beginning",
    },

    navigation_beginning = {
      mod = "navigation",
      func = "navigation_beginning",
    },

    navigation_reset = {
      mod = "navigation",
      func = "navigation_reset",
    },

  }
}

return conf
