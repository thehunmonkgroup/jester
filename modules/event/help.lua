jester.help_map.event = {}
jester.help_map.event.description_short = [[Interact with the FreeSWITCH event system.]]
jester.help_map.event.description_long = [[This module provides actions for interacting with the FreeSWITCH event system.]]

jester.help_map.event.actions = {}

jester.help_map.event.actions.fire_event = {}
jester.help_map.event.actions.fire_event.description_short = [[Fires a custom event.]]
jester.help_map.event.actions.fire_event.description_long = [[Fires a custom event.  Event-Name will be 'CUSTOM', and Event-Subclass will be '[subclass]::[event_type]'.

The body will automatically have two newline characters appended to it.]]
jester.help_map.event.actions.fire_event.params = {
  subclass = [[(Optional) The first portion of the Event-Subclass header (before the double colons). Default is 'jester'.]],
  event_type = [[The second portion of the Event-Subclass header (after the double colons).]],
  headers = [[(Optional) A table of event headers, key = header name, value = header description.  Note that some headers will need to use the full table key syntax, eg. 'headers = {["Custom-Value"] = "foo"}'.]],
  header_prefix = [[(Optional) Prefix all header keys with this string. Defaults to 'Jester-'.]],
  body = [[(Optional) The event body.]],
}

