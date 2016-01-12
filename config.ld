project = "Jester"
description = "Scripting toolkit for FreeSWITCH"
--package = "jester"
title = "Jester documentation"
file = {
  "./modules/data/data.lua",
}
dir = "./documentation"
topics = {
  "./help"
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
--custom_css = "ldoc.custom.css"

-- vi: ft=lua
