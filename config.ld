project = "Jester"
description = "Scripting toolkit for FreeSWITCH"
--package = "jester"
title = "Jester documentation"
file = {
  "conf.lua",
  "./modules/core_actions/core_actions.lua",
  "./modules/couchdb/couchdb.lua",
  "./modules/data/data.lua",
  "./modules/dialplan_tools/dialplan_tools.lua",
  "./modules/email/email.lua",
  "./modules/event/event.lua",
  "./modules/file/file.lua",
  "./modules/format/format.lua",
  "./modules/get_digits/get_digits.lua",
  "./modules/hangup/hangup.lua",
  "./modules/log/log.lua",
  "./modules/navigation/navigation.lua",
  "./modules/play/play.lua",
}
dir = "./documentation"
topics = {
  "./doc"
}
format = "markdown"
all = true
--examples = "./examples"
wrap = true
no_space_before_args = true
style = "!fixed"
new_type("action", "Actions")
new_type("handler", "Handlers")
-- This is a custom setting not currently available in LDoc, see
-- https://github.com/stevedonovan/LDoc/pull/223
custom_css = "ldoc.custom.css"

-- vi: ft=lua
