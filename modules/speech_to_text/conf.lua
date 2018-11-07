local conf = {
  action_map = {

    speech_to_text_from_file = {
      mod = "speech_to_text",
      handlers = {
        -- AT&T's API appears to have died.
        -- att = "speech_to_text_from_file_att",
        -- Google changed things so their API is not longer generally accessible.
        -- google = "speech_to_text_from_file_google",
        watson = "speech_to_text_from_file_watson",
        default = "speech_to_text_from_file_watson",
      }
    },

  }
}

return conf
