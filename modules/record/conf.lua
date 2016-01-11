local conf = {
  action_map = {

    record = {
      mod = "record",
      handlers = {
        file = "record_file",
        default = "record_file",
      }
    },

    record_merge = {
      mod = "record",
      handlers = {
        file = "record_file_merge",
        default = "record_file_merge",
      }
    },

  }
}

return conf
