local conf = {
  action_map = {

    execute = {
      mod = "dialplan_tools",
      func = "execute",
    },

    transfer = {
      mod = "dialplan_tools",
      func = "transfer",
    },

    bridge = {
      mod = "dialplan_tools",
      func = "bridge",
    },

  }
}

return conf
