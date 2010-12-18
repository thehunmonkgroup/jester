-- sequences
jester.help_map.sequences = {}
jester.help_map.sequences.description_short = [[How to build voice workflows with sequences.]]
jester.help_map.sequences.description_long = [[A sequence is a series of actions that are executed in a sequential order.

Sequences are the primary control mechanism for building workflows in Jester.]]

-- sequences -> keys
jester.help_map.sequences.keys = {}
jester.help_map.sequences.keys.description_short = [[Introduction on how to capture user key input.]]
jester.help_map.sequences.keys.description_long = [[Jester provides high-level implementations for acting on keys pressed by the user.

To maintain the simplicity of the engine, menu-type navigation is limited to single digits.  Any action that has the 'keys' parameter supports responding to key presses.  The layout of the keys parameter is as follows:

keys = {
  ["1"] = "someothersequence",
  ["2"] = "somesequence arg1,arg2",
  ["3"] = "@someaction",
  ["4"] = ":break",
  ["5"] = ":seek:+2000",
  ["6"] = ":seek:-2000",
  ["7"] = ":pause",
  ["*"] = "@navigation_up",
  invalid = true,
  invalid_sound = "ivr/ivr-that_was_an_invalid_entry.wav",
  invalid_sequence = "mysequence arg1,arg2"
}

The key itself is enclosed in square brackets and quotes.  The values for each key can be in one of three forms:

  1. A sequence to run (with arguments if desired)
  2. An action to run directly (not common besides navigation)
  3. A special playback operator

Sequences are called in the same format as they are anywhere else in Jester.  When a sequence is called, the key press is registered as valid, playback of the file is stopped, the currently running action is terminated, and the new sequence is called.

Actions are preceded by the @ symbol.

Actions run this way are run in 'ad hoc' mode -- they can accept no key presses, and the previously running action will be returned to if the ad hoc action does not call a new sequence.  The navigation actions are the most likely actions to be run in this form.

Playback operators are preceeded by a colon.

The common playback operators are as follows (there are others, check the lua scripts in the FreeSWITCH source for more):
  :break
    Break playback or recording of a file
  :seek:+<milliseconds>
    Fast forward through a playing file.  Replace [milliseconds] with the number of milliseconds to fast forward.
  :seek:-<milliseconds>
    Rewind through a playing file.  Replace [milliseconds] with the number of milliseconds to rewind.
  :seek:0
    Begin playback of a file from the beginning.
  :pause
    Pause a playing file.  If the file is already paused, resume playback.

There are three extra parameters besides the keys that can be used to control how invalid key presses are handled.  The default, if none of these are present, is to simply ignore the key press:

  invalid:
    Set this to true if you just want to register the key press as invalid and break the currently running action.
  invalid_sound:
    Set this to a file or phrase to play to the user after registering the key press as invalid and stopping playback of the file.  The format of the filepath is the same as the ones accepted by the play module.
  invalid_sequence:
    Set this to a sequence to call after registering the key press as invalid and stopping playback of the file.

The keys parameter can be put in one of two places:
  As an action parameter:
    This sets the key mapping for just the action that it's defined.  eg.
      return
      {
        {
          action = "play",
          file = "myfile",
          keys = {
            ['#'] = ':break',
          },
        },
      }
      In this case, once the action is complete, the mapping is cleared.
  As a sequence parameter:
    This sets the key mapping for all actions in the sequence.  eg.
      return
      {
        keys = {
          ['#'] = ':break',
        },
        {
          action = "play",
          file = "myfile",
        },
        {
          action = "record",
          file = "myrecording",
        },
      }
      In this case, once the sequence is complete, the mapping is cleared.  Note that individual action in the sequence can still provide their own key mappings, and they will override the sequence mapping for that action.]]

-- sequences -> variables
jester.help_map.sequences.variables = {}
jester.help_map.sequences.variables.description_short = [[How to access and use variables in sequences.]]
jester.help_map.sequences.variables.description_long = [[Sequences can use variables from four places:

  Global configuration:
    Variables defined in jester/conf.lua can be accessed through the 'global' namespace, eg. 'global.base_dir' accesses the 'base_dir' variable from the global configuration.
  Profile configuration:
    Variables defined in the running profile's conf.lua can be accessed through the 'profile' namespace, eg. 'profile.mailbox_dir' accesses the 'mailbox_dir' variable from the profile configuration.
  Channel variables:
    Variables defined in the current FreeSWITCH channel that Jester is running in can be accessed through the 'variable()' function, eg. 'variable("caller_id_name")' accesses the 'caller_id_name' variable from the channel.
  Jester's internal storage system:
    Variables defined in Jester's internal storage can be accessed through the 'storage()' function, eg. 'storage("mailbox_settings", "mailbox")' accesses the value of the 'mailbox' key from the 'mailbox_settings' storage area.  See 'help storage' to learn more.]]

