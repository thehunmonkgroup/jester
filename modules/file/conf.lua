local conf = {
  action_map = {

    create_directory = {
      mod = "file",
      handlers = {
        filesystem = "create_directory",
        default = "create_directory",
      }
    },

    remove_directory = {
      mod = "file",
      handlers = {
        filesystem = "remove_directory",
        default = "remove_directory",
      }
    },

    move_file = {
      mod = "file",
      handlers = {
        filesystem = "move_file",
        default = "move_file",
      }
    },

    delete_file = {
      mod = "file",
      handlers = {
        filesystem = "delete_file",
        default = "delete_file",
      }
    },

    file_exists = {
      mod = "file",
      handlers = {
        filesystem = "file_exists",
        default = "file_exists",
      }
    },

    file_size = {
      mod = "file",
      handlers = {
        filesystem = "file_size",
        default = "file_size",
      }
    },

  }
}

return conf
