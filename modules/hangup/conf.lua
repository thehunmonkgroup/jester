local conf = {
  action_map = {

    hangup = {
      mod = "hangup",
      func = "hangup"
    },

    hangup_sequence = {
      mod = "hangup",
      func = "register_hangup_sequence"
    },

  }
}

return conf
