local conf = {
  action_map = {

    none = {
      mod = "core_actions",
      func = "none",
    },

    call_sequence = {
      mod = "core_actions",
      func = "call_sequence",
    },

    conditional = {
      mod = "core_actions",
      func = "conditional",
    },

    set_variable = {
      mod = "core_actions",
      func = "set_variable",
    },

    set_storage = {
      mod = "core_actions",
      func = "set_storage",
    },

    copy_storage = {
      mod = "core_actions",
      func = "copy_storage",
    },

    clear_storage = {
      mod = "core_actions",
      func = "clear_storage",
    },

    exit_sequence = {
      mod = "core_actions",
      func = "register_exit_sequence",
    },

    wait = {
      mod = "core_actions",
      func = "wait",
    },

    load_profile = {
      mod = "core_actions",
      func = "load_profile",
    },

    api_command = {
      mod = "core_actions",
      func = "api_command",
    },

  }
}

return conf

