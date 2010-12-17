jester.help_map.tracker = {}
jester.help_map.tracker.description_short = [[Track various states in the channel.]]
jester.help_map.tracker.description_long = [[This module provides actions assist in tracking various states in a channel.]]

jester.help_map.tracker.actions = {}

jester.help_map.tracker.actions.counter = {}
jester.help_map.tracker.actions.counter.description_short = [[Incremental custom variable counter.]]
jester.help_map.tracker.actions.counter.description_long = [[This action provides a simple method to keep a count of any arbitrary value, provides access to calling sequences by comparing a number against the total in the counter.  It's useful for storing how many times you've done something, eg. on 3rd failed login attempt, hang up.  Counters are initialized with a value of zero, and placed in storage area 'counter'.]]
jester.help_map.tracker.actions.counter.params = {
  storage_key = [[(Optional) The key in the 'counter' storage area where the counter value is stored and checked.  Default is 'counter']],
  increment = [[(Optional) Increment the counter by this amount before performing the comparison to the 'compare_to' parameter.  Negative increments are allowed.  The default is to not increment the counter.]],
  reset = [[(Optional) Set to true to reset the counter to zero.  This happens before any incrementing, so it can be used with incrementing to set a new initial value for the counter.]],
  compare_to = [[(Optional) The value to compare the current counter value against.]],
  if_less = [[(Optional) The sequence to call if the counter value is less than the 'compare_to' value.]],
  if_equal = [[(Optional) The sequence to call if the counter value is equal to the 'compare_to' value.]],
  if_greater = [[(Optional) The sequence to call if the counter value is greater than the 'compare_to' value.]],
}

