local conf = {
  action_map = {
    log = {
      mod = "log",
      handlers = {
        console = "log_console",
        file = "log_file",
        default = "log_console",
      }
    }
  }
}

return conf
