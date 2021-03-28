require "jester.support.string"

function standardize_output(output)
  local lines = output:split("\n")
  if lines[#lines] == "" then
    table.remove(lines)
  end
  return lines
end

function run_shell_command(command, collect_stderr)
  if collect_stderr then
    command = string.format([[%s  2>&1]], command)
  end
  -- This will open the file
  local file = io.popen(command)
  -- This will read all of the output
  local output = file:read('*all')
  -- This will get a table with some return stuff
  -- rc[1] will be true, false or nil
  -- rc[3] will be the signal
  local rc = {file:close()}
  local success = rc[1]
  return success, output
end
