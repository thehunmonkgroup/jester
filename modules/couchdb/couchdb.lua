--[[
  Interface to CouchDB via Luchia.
]]

local document = require "luchia.document"
local http_code_ok = 200

module(..., package.seeall)

--[[
  Sets up a new document handler.
]]
local function doc_handler(action)
  local database = action.database
  local server = action.server
  if database then
    local doc = document:new(database, server)
    if type(doc) == "table" then
      jester.debug_log("New document handler for database: %s", action.database)
      return doc
    end
  end
end

--[[
  CouchDB action handlers.
]]

function retrieve(action)
  local path = action.path
  local params = action.query_parameters
  local storage_area = action.storage_area or "couchdb_retrieve"
  jester.clear_storage(storage_area)
  local doc = doc_handler(action)
  if doc then
    local resp, code = doc:retrieve(path, params)
    if code == http_code_ok then
      jester.debug_log("Path '%s' retrieved from database: %s", path, action.database)
      jester.set_storage(storage_area, "data", resp)
    end
  end
end


function retrieve_document(action)
  local id = action.document_id
  local params = action.query_parameters
  local storage_area = action.storage_area or "couchdb_retrieve_document"
  jester.clear_storage(storage_area)
  local doc = doc_handler(action)
  if doc then
    local resp, code = doc:retrieve(id, params)
    if code == http_code_ok then
      jester.debug_log("Document ID '%s' retrieved from database: %s", resp._id, action.database)
      jester.set_storage(storage_area, "id", resp._id)
      jester.set_storage(storage_area, "rev", resp._rev)
      jester.set_storage(storage_area, "document", resp)
    end
  end
end

function create_document(action)
  local data = action.document
  local id = action.document_id
  local storage_area = action.storage_area or "couchdb_create_document"
  jester.clear_storage(storage_area)
  local doc = doc_handler(action)
  if doc then
    local resp = doc:create(data, id)
    if doc:response_ok(resp) then
      jester.debug_log("New document created for database: %s, id: %s", action.database, resp.id)
      jester.set_storage(storage_area, "id", resp.id)
      jester.set_storage(storage_area, "rev", resp.rev)
    end
  end
end

function update_document(action)
  local data = action.document
  local id = action.document_id
  local rev = action.document_rev
  local storage_area = action.storage_area or "couchdb_update_document"
  jester.clear_storage(storage_area)
  local doc = doc_handler(action)
  if doc then
    local resp = doc:update(data, id, rev)
    if doc:response_ok(resp) then
      jester.debug_log("Document id '%s' updated for database: %s", resp.id, action.database)
      jester.set_storage(storage_area, "id", resp.id)
      jester.set_storage(storage_area, "rev", resp.rev)
    end
  end
end

function delete_document(action)
  local id = action.document_id
  local rev = action.document_rev
  local storage_area = action.storage_area or "couchdb_delete_document"
  jester.clear_storage(storage_area)
  local doc = doc_handler(action)
  if doc then
    local resp = doc:delete(id, rev)
    if doc:response_ok(resp) then
      jester.debug_log("Document id '%s' deleted from database: %s", resp.id, action.database)
      jester.set_storage(storage_area, "id", resp.id)
      jester.set_storage(storage_area, "rev", resp.rev)
    end
  end
end

function retrieve_attachment(action)
  local id = action.document_id
  local name = action.attachment_name
  local file_path = action.file_path
  local storage_area = action.storage_area or "couchdb_retrieve_attachment"
  jester.clear_storage(storage_area)
  local doc = doc_handler(action)
  if doc then
    local file_data, code = doc:retrieve_attachment(name, id)
    if code == http_code_ok then
      -- Write out retrieved file data.
      local file = io.open(file_path, "w")
      if file then
        if file:write(file_data) then
          jester.debug_log("Attachment '%s' retrieved from document ID '%s' in database '%s', written to file '%s'.", name, id, action.database, file_path)
          jester.set_storage(storage_area, "attachment_name", name)
          jester.set_storage(storage_area, "file_path", file_path)
        end
        file:close()
      end
    end
  end
end

function add_attachment(action)
  local file_path = action.file_path
  local content_type = action.content_type
  local name = action.attachment_name
  local id = action.document_id
  local rev = action.document_rev
  local storage_area = action.storage_area or "couchdb_add_attachment"
  jester.clear_storage(storage_area)
  local doc = doc_handler(action)
  if doc then
    local resp = doc:add_standalone_attachment(file_path, content_type, name, id, rev)
    if doc:response_ok(resp) then
      jester.debug_log("File '%s' added as attachment '%s' to document ID '%s' in database: %s", file_path, name, resp.id, action.database)
      jester.set_storage(storage_area, "id", resp.id)
      jester.set_storage(storage_area, "rev", resp.rev)
    end
  end
end

function delete_attachment(action)
  local name = action.attachment_name
  local id = action.document_id
  local rev = action.document_rev
  local storage_area = action.storage_area or "couchdb_delete_attachment"
  jester.clear_storage(storage_area)
  local doc = doc_handler(action)
  if doc then
    local resp = doc:delete_attachment(name, id, rev)
    if doc:response_ok(resp) then
      jester.debug_log("Attachment '%s' deleted from  document ID '%s' in database: %s", name, resp.id, action.database)
      jester.set_storage(storage_area, "id", resp.id)
      jester.set_storage(storage_area, "rev", resp.rev)
    end
  end
end

