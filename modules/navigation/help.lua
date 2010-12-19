jester.help_map.navigation = {}
jester.help_map.navigation.description_short = [[Menu/phone tree navigation.]]
jester.help_map.navigation.description_long = [[This module provides actions that help with navigating menus and phone trees.]]

jester.help_map.navigation.actions = {}

jester.help_map.navigation.actions.add_to_stack = {}
jester.help_map.navigation.actions.add_to_stack.description_short = [[Add a sequence to the navigation stack.]]
jester.help_map.navigation.actions.add_to_stack.description_long = [[This action adds a sequence to the navigation stack.  It can be used for tracking when a channel moves deeper into a menu tree.  Adding a sequence to the stack allows for using the navigation actions to traverse back up the stack.]]
jester.help_map.navigation.actions.add_to_stack.params = {
  sequence = [[(Optional) The sequence to add to the stack.  Defaults to the currently running sequence.]],
}

jester.help_map.navigation.actions.navigation_up = {}
jester.help_map.navigation.actions.navigation_up.description_short = [[Move up the navigation stack one position]]
jester.help_map.navigation.actions.navigation_up.description_long = [[This action pops the current action off the navigation stack, and executes the next item up in the stack.  It can be used for providing 'previous menu' functionality in phone trees.

This action is most often used in the 'keys' array like so:

  keys = {
    ["9"] = "@navigation_up"
  }

It can however be used in a regular sequence as well.]]

jester.help_map.navigation.actions.navigation_clear = {}
jester.help_map.navigation.actions.navigation_clear.description_short = [[Clear the navigation stack]]
jester.help_map.navigation.actions.navigation_clear.description_long = [[This action clears the navigation stack.  No sequences will be left on the stack after this operation.]]

jester.help_map.navigation.actions.navigation_top = {}
jester.help_map.navigation.actions.navigation_top.description_short = [[Move to the top of the navigation stack]]
jester.help_map.navigation.actions.navigation_top.description_long = [[This action clears the navigation stack, and executes the first item from the old stack, placing it at the top of the new stack.  It can be used for providing 'return to beginning' functionality in phone trees.

This action is most often used in the 'keys' array like so:

  keys = {
    ["9"] = "@navigation_top"
  }

It can however be used in a regular sequence as well.]]

jester.help_map.navigation.actions.navigation_reset = {}
jester.help_map.navigation.actions.navigation_reset.description_short = [[Set the current sequence as the new navigation stack top]]
jester.help_map.navigation.actions.navigation_reset.description_long = [[This action clears the navigation stack, and sets the last item in the old stack to be the first item in the new stack.  It can be used to set a new 'top' for the navigation stack.]]

