jester.help_map.dialplan_tools = {}
jester.help_map.dialplan_tools.description_short = [[Provides access to dialplan applications.]]
jester.help_map.dialplan_tools.description_long = [[This module provides access to various dialplan applications.  An understand of how these applications are used in FreeSWITCH dialplans is essential in order to properly use the actions in this module.]]

jester.help_map.dialplan_tools.actions = {}

jester.help_map.dialplan_tools.actions.execute = {}
jester.help_map.dialplan_tools.actions.execute.description_short = [[Execute dialplan applications.]]
jester.help_map.dialplan_tools.actions.execute.description_long = [[This action provides access to execute any dialplan application via Jester.  Note that key presses will not be recognized during the execute action, use the various play and record actions to allow capturing of key presses.]]
jester.help_map.dialplan_tools.actions.execute.params = {
  application = [[The application to execute.]],
  data = [[(Optional) Data to pass to the application.]],
}

jester.help_map.dialplan_tools.actions.transfer = {}
jester.help_map.dialplan_tools.actions.transfer.description_short = [[Transfer to another extension in the dialplan.]]
jester.help_map.dialplan_tools.actions.transfer.description_long = [[This action is used to transfer to another extension in the dialplan.  Prior to the transfer, the active sequence stack is cleared.]]
jester.help_map.dialplan_tools.actions.transfer.params = {
  extension = [[The extension to transfer to.]],
  dialplan = [[(Optional) The dialplan to transfer to.  Default is 'XML'.]],
  context = [[(Optional) The context to transfer to.  Default is the current context.]],
}

jester.help_map.dialplan_tools.actions.bridge = {}
jester.help_map.dialplan_tools.actions.bridge.description_short = [[Bridges the current Jester channel with another endpoint.]]
jester.help_map.dialplan_tools.actions.bridge.description_long = [[This action bridges the current channel with another endpoint.

Note that many characteristics of the bridge can be controlled by setting various channel variables prior to the bridge.  Check the FreeSWITCH wiki for more information on the available channel variables, and 'help action set_variable' for setting channel variables from Jester.]]
jester.help_map.dialplan_tools.actions.bridge.params = {
  channel = [[The channel to use for the bridge.  Can be a string (used for all extensions), or optionally a table of multiple channels (used with the matching extension in the extension table).  Be sure to include everything up to the actual extension, including trailing slash and any dial prefix.]],
  extension = [[The extension to bridge to.  Can be a string (used for all channels), or optionally a table of multiple extensions (used with the matching channel in the channel table).]],
  variables = [[A table of channel variables to set for the bridge, key = variable name, value = variable value.  Can be a single table (used for all channels), or optionally a table of variable tables (used with the matching channel in the channel list).]],
  multichannel_type = [[(Optional) If multiple channels or extensions are specified, this setting determines how they will be connected. 'first_wins' rings all channels until the first responds with media, then bridges that channel.  'sequential' rings each channel in succession, bridging the first one that responds with media.  Default is first_wins'.]],
  hangup_after_bridge = [[(Optional) If set to true, the call will be hungup after the bridge completes.  Note that all sequences registered for the exit and hangup loops will still be run.]],
}

