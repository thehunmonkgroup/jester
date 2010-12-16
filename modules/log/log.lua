module(..., package.seeall)

function log_console(action)
  jester.log(action.message, "JESTER LOG", action.level)
end

