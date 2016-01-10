local conf = {
  action_map = {

    couchdb_retrieve = {
      mod = "couchdb",
      func = "retrieve",
    },

    couchdb_retrieve_document = {
      mod = "couchdb",
      func = "retrieve_document",
    },

    couchdb_create_document = {
      mod = "couchdb",
      func = "create_document",
    },

    couchdb_update_document = {
      mod = "couchdb",
      func = "update_document",
    },

    couchdb_delete_document = {
      mod = "couchdb",
      func = "delete_document",
    },

    couchdb_add_attachment = {
      mod = "couchdb",
      func = "add_attachment",
    },

    couchdb_retrieve_attachment = {
      mod = "couchdb",
      func = "retrieve_attachment",
    },

    couchdb_delete_attachment = {
      mod = "couchdb",
      func = "delete_attachment",
    },

  }
}

return conf
