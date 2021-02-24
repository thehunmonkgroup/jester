project = "Jester"
description = "Scripting toolkit for FreeSWITCH"
--package = "jester"
title = "Jester documentation"
file = {
  -- Core.
  "./core.lua",
  "./conf.lua",
  -- Modules.
  "./modules/core_actions/init.lua",
  "./modules/couchdb/init.lua",
  "./modules/data/init.lua",
  "./modules/dialplan_tools/init.lua",
  "./modules/email/init.lua",
  "./modules/event/init.lua",
  "./modules/file/init.lua",
  "./modules/format/init.lua",
  "./modules/get_digits/init.lua",
  "./modules/hangup/init.lua",
  "./modules/log/init.lua",
  "./modules/navigation/init.lua",
  "./modules/play/init.lua",
  "./modules/record/init.lua",
  "./modules/service/init.lua",
  "./modules/speech_to_text/init.lua",
  "./modules/speech_to_text/watson.lua",
  "./modules/system/init.lua",
  "./modules/tracker/init.lua",
  -- Scripts.
  "./socket.lua",
  "./scripts/extract_actions.lua",
  "./action_map.lua",
}
dir = "./documentation"
topics = {
  "./doc"
}
format = "markdown"
all = false
examples = "./examples"
wrap = true
no_space_before_args = true
style = "!fixed"
new_type("action", "Actions")
new_type("handler", "Handlers")
custom_css = "ldoc.custom.css"

-- vi: ft=lua
