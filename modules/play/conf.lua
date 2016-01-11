local conf = {
  action_map = {

    play = {
      mod = "play",
      handlers = {
        file = "play_file",
        default = "play_file",
      }
    },

    play_valid_file = {
      mod = "play",
      handlers = {
        file = "play_valid_file",
        default = "play_valid_file",
      }
    },

    play_phrase = {
      mod = "play",
      func = "play_phrase_macro"
    },

    play_keys = {
      mod = "play",
      func = "play_key_macros"
    },

  }
}

return conf
