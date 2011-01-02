jester.help_map.event = {}
jester.help_map.event.description_short = [[Interact with the FreeSWITCH event system.]]
jester.help_map.event.description_long = [[This module provides actions for interacting with the FreeSWITCH event system.]]

jester.help_map.event.actions = {}

jester.help_map.event.actions.fire_event = {}
jester.help_map.event.actions.fire_event.description_short = [[Fires a custom event.]]
jester.help_map.event.actions.fire_event.description_long = [[Fires a custom event.  The event name will be 'CUSTOM', and the event type will be 'jester::[event_type]'.

All headers will be prefixed with 'Jester-', and the body will automatically have two newline characters appended to it.]]
jester.help_map.event.actions.fire_event.params = {
  event_type = [[The event type.]],
  headers = [[(Optional) A table of event headers, key = header name, value = header description.  Note that some headers will need to use the full table key syntax, eg. 'headers = {["Custom-Value"] = "foo"}'.]],
  body = [[(Optional) The event body.]],
}

