module(..., package.seeall)

require "jester.support.string"

local script_path, is_freeswitch = "", false
if jester.is_freeswitch then
  local api = freeswitch.API()
  local base_dir = api:executeString("global_getvar base_dir")
  script_path = base_dir .. "/scripts/"
end

function init_module_help()
  local help_file
  -- Create a map of all module help that can be called.
  jester.help_map = {}
  for _, mod in ipairs(jester.conf.modules) do
    help_file = "jester.modules." .. mod .. ".help"
    if require(help_file) then
      jester.debug_log("Loaded module help '%s'", help_file)
    else
      jester.debug_log("Failed loading module help '%s'!", help_file)
    end
  end
end

function get_help(topic, subtopic, ...)
  local file, output, takes_args
  if topic then
    if subtopic then
      file = topic .. "_" .. subtopic
    else
      file = topic
    end
  else
    file = "topics"
  end
  local f, e = loadfile(script_path .. jester.conf.help_path .. "/" .. file .. ".lua")
  if f then
    output = f()
  else
    -- Try loading the topic, it may take arguments.
    f, e = loadfile(script_path .. jester.conf.help_path .. "/" .. topic .. ".lua")
    if f then
      output, takes_args = f(subtopic, ...)
      -- The topic doesn't take arguments, wipe the output.
      if not takes_args then output = nil end
    end
  end
  if not output then
    output = string.format("No help available for %s: %s", file, tostring(e))
  end
  help_output(output)
end

function help_output(help)
  if jester.is_freeswitch then
    freeswitch.consoleLog("info", "\n" .. tostring(help) .. "\n")
  else
    print("\n" .. help .. "\n")
  end
end

