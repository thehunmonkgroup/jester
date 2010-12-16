jester.action_map.data_load = {
  mod = "data",
  handlers = {
    odbc = "load_data_odbc",
    default = "load_data_odbc",
  }
}
jester.action_map.data_update = {
  mod = "data",
  handlers = {
    odbc = "update_data_odbc",
    default = "update_data_odbc",
  }
}
jester.action_map.data_delete = {
  mod = "data",
  handlers = {
    odbc = "delete_data_odbc",
    default = "delete_data_odbc",
  }
}

