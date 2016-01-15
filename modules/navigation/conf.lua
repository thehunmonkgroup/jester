local conf = {
  action_map = {

    -- Alias for add_to_navigation, to maintain backwards compat.
    add_to_stack = {
      mod = "navigation",
      func = "add_to_navigation",
    },

    add_to_navigation = {
      mod = "navigation",
      func = "add_to_navigation",
    },

    navigation_up = {
      mod = "navigation",
      func = "navigation_up",
    },

    navigation_clear = {
      mod = "navigation",
      func = "navigation_clear",
    },

    navigation_top = {
      mod = "navigation",
      func = "navigation_top",
    },

    navigation_reset = {
      mod = "navigation",
      func = "navigation_reset",
    },

  }
}

return conf
