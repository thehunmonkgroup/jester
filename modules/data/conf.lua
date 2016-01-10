local conf = {
  action_map = {

    data_load = {
      mod = "data",
      handlers = {
        odbc = "load_data_odbc",
        default = "load_data_odbc",
      }
    },

    data_load_count = {
      mod = "data",
      handlers = {
        odbc = "load_data_count_odbc",
        default = "load_data_count_odbc",
      }
    },

    data_update = {
      mod = "data",
      handlers = {
        odbc = "update_data_odbc",
        default = "update_data_odbc",
      }
    },

    data_delete = {
      mod = "data",
      handlers = {
        odbc = "delete_data_odbc",
        default = "delete_data_odbc",
      }
    },

    data_query = {
      mod = "data",
      handlers = {
        odbc = "query_data_odbc",
        default = "query_data_odbc",
      }
    },

  }
}

return conf
