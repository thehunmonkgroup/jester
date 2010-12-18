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
jester.help_map.sequences.variables.description_long = [[Variables in sequences are standard Lua variable definitions:
  name = value

You can assign variables to other variables you create in the sequence itself, and to the set of outside variables detailed below.  Variable names can be any string of letters, digits and underscores, not beginning with a digit.

To avoid namespace collisions in your sequence, the following variable names are prohibited:
  global
  profile
  args
  variable
  storage
  debug_dump

Sequences can access outside variables from five places:

  Global configuration:
    Variables defined in jester/conf.lua can be accessed through the 'global' namespace, eg. 'foo = global.base_dir' accesses the 'base_dir' variable from the global configuration.
  Profile configuration:
    Variables defined in the running profile's conf.lua can be accessed through the 'profile' namespace, eg. 'foo = profile.mailbox_dir' accesses the 'mailbox_dir' variable from the profile configuration.
  Channel variables:
    Variables defined in the current FreeSWITCH channel that Jester is running in can be accessed through the 'variable()' function, eg. 'foo = variable("caller_id_name")' accesses the 'caller_id_name' variable from the channel.
  Jester's internal storage system:
    Variables defined in Jester's internal storage can be accessed through the 'storage()' function, eg. 'foo = storage("mailbox_settings", "mailbox")' accesses the value of the 'mailbox' key from the 'mailbox_settings' storage area.  See 'help sequences storage' to learn more.
  Sequence arguments:
    Sequences can be called with arguments, and these can be accessed through the args() function, eg. 'foo = args(1) accesses the first argument passed to the sequence.  See 'help sequences arguments' for more information.]]

-- sequences -> format
jester.help_map.sequences.format = {}
jester.help_map.sequences.format.description_short = [[Learn the structure of writing a sequence.]]
jester.help_map.sequences.format.description_long = [[At it's heart, a sequence is a Lua script.  If you are familiar with Lua syntax, then writing sequences should be quite trivial.  If you're new to Lua, check out 'help intro lua' for a primer on the basic syntax that will be used in sequences.

A sequence is a list of 'actions' to take in a certain order, very similar to how commands would be executed sequentially in a dialplan extension.

The most simple sequence you can write illustrates its basic format:

  return
  {
    {
      action = "none",
    },
  }

This sequence calls the "none" action, which is just a passthrough.  This is a sequence (the outer curly brackets), with one action (the second set of curly braces around the 'action' parameter).  For more on how to write actions, see 'help sequences actions'

Here's a slightly more complex sequence:

  mailbox = variable("mailbox_number")
  record_location = storage("custom", "where_to_record")

  return
  {
    {
      action = play,
      file = "/var/voicemail/" .. mailbox_number .. "/greeting.wav",
    },
    {
      action = record,
      location = record_location .. "/messages",
    },
  }

As you can see, sequences can contain variables.  They can also use conditional statements and concatenate strings (in fact, they can actually do everything a Lua script can do, minus accessing the standard libraries, but that is beyond the scope of this tutorial).  See 'help sequences variables' for more information on using variables in sequences, and 'help sequences tricks' for more creative sequence designs.

The last example illustrates a basic design point of sequences.  You can think of everything above the 'return' statement as a scratch pad, where you can assemble the necessary variables and perform other tasks to prepare things to be used in the actual sequence -- and everything below the 'return' statement as the final sequence you give to Jester for executing.

One important thing to note is that Jester re-evaluates the entire sequence before each sequence action is run.  In a practical sense this means that if you set a variable in action #1, that variable's value will be available in action #2.  This is a very useful feature!  On the down side, this also means that Jester core has to do a lot of evaluating, which could have an impact on high load systems.  For this reason it is recommended that if you're going to use any channel variables or storage items more than once in your sequence, you should define a variable for them in the top section, and use that variable when writing actions.

For an easy way to generate templates for sequences, see 'help scripts jsequence'.]]


-- sequences -> actions
jester.help_map.sequences.actions = {}
jester.help_map.sequences.actions.description_short = [[How to write actions, the building blocks of sequences.]]
jester.help_map.sequences.actions.description_long = [[Actions are the mechanism for doing something in a sequence.  They are configurable templates that allow you to pass a command and command options to Jester, which are then passed on to the module providing the action for execution.  Put simply, you give the module a few simple instructions, and it handles the dirty work of accomplishing the job through the FreeSWITCH/Lua API.

Each action is a Lua table within the main sequence (for more information on overall sequence design, see 'help sequences format').  The table is a series of key/value pairs (called parameters from here out) that contain the action instructions.  Here's an example of the 'play' action, which plays a sound file on the channel:

  {
    action = "play",
    file = "/tmp/mysoundfile.wav",
    keys = {
      ["#"] = ":break",
    },
    repetitions = 2,
    wait = 3000,
  },

An action always has at least one required parameter, 'action', which is the action to execute.  The other parameters are dependant on the action being taken, see 'help actions' for a list of all available actions, and 'help action [name]' for detailed help on a particular action, including the parameters it accepts.

For an easy way to generate templates for actions, see 'help scripts jsequence'.]]

-- sequences -> hangup
jester.help_map.sequences.hangup = {}
jester.help_map.sequences.hangup.description_short = [[How to trigger actions on hangup/exit.]]
jester.help_map.sequences.hangup.description_long = [[Sometimes you need to make sure a sequence is run regardless if the user hangs up the call, or otherwise leaves the Jester environment.

Jester accomodates this by providing two places where you can register sequences to run at a later time:
  On hangup:
    See 'help action hangup_sequence'
  After the last active sequence ends:
    See 'help action exit_sequence']]

-- sequences -> debug
jester.help_map.sequences.debug = {}
jester.help_map.sequences.debug.description_short = [[How to debug sequences.]]
jester.help_map.sequences.debug.description_long = [[Sometimes you'll be designing a sequence, it's either crashing Jester or not behaving as you would expect, and you can't easily figure out why.  Jester provides a few debugging utilities to aid your investigative efforts:

  Turn on Jester's debug output:
    This can be done globally by setting the 'debug' variable to true in 'jester/conf.lua', or per profile by setting the same variable in the profile.  Turning this one outputs a massive amount of debugging information, pretty much detailing every single thing Jester is doing as it runs.

  Use debug_dump() in your sequence:
    Jester exposes its core variable dumping function to all sequences.  You can place it in the top section of any sequence, give it a variable name, and it will dump the variable to the FreeSWITCH console.  For example, to debug the 'foo' variable:
      debug_dump(foo)

Syntax errors can be hard to debug.  If you have one in your sequence Jester will most assuredly crash, and you can check the FreeSWITCH console for the error message.  Usually it contains some helpful information pointing you to a line number and a suggestion what the problem might be.  The most common mistakes are:

  Missing a closing curly brace on the sequence, an action, or an action parameter.
  Missing a comma at the end of a parameter or an action.
  Trying to concatenate something that has no value.
  Using = in a conditional when you meant ==.]]

-- sequences -> conditionals
jester.help_map.sequences.conditional = {}
jester.help_map.sequences.conditional.description_short = [[How to add simple decision-making to sequences.]]
jester.help_map.sequences.conditional.description_long = [[At certain points in a sequence, you may want to take different actions based on the value of some channel variable or storage item.  Jester provides a simple mechanism to do this, the 'conditional' action.

It allows you to compare one value with another with various strategies, and call a new sequence based on if the comparison is true or false.  An example conditonal would be:

  {
    action = "conditional",
    value = number_of_messages,
    compare_to = 0,
    comparison = "equal",
    if_true = "exit",
    if_false = "play_messages",
  },

See 'help action conditional' for more details.]]

-- sequences -> subsequences
jester.help_map.sequences.subsequences = {}
jester.help_map.sequences.subsequences.description_short = [[Subroutines for sequences.]]
jester.help_map.sequences.subsequences.description_long = [[At certain points in a sequence, it may be desirable to fire off another sequence, and when it completes have Jester return to the previously running sequence.  Subsequences allow you to accomplish this.

Jester's basic logic is to run one sequence and then exit.  It will only run other sequences if you specifically tell it to.  Normally, when you call one sequence from another, the original sequence is forgotten and the new sequence is run -- ie, only one sequence at a time runs.

To allow you to run more than one sequence at a time, Jester keeps a 'sequence stack'.  It runs sequences at a stack level until no more are called, then it checks to see if there's another level above it.  If so, it returns to that level and continues running the sequence at that level, and so on until finally there are no more stack levels and Jester exits.

To operate on the sequence stack, you prefix your calls to a sequence with one of three commands:
  sub:
    This moves the sequence stack down one level, and runs the called sequence there, remembering which action the current sequence is running.  When the lower level stack finishes, the stack level is discarded, Jester moves up on level in the sequence stack, and continues with the next action in the seqeunce at that level:
      eg. 'sub:mysubsequence' calls the 'mysubsequence' sequence in the next stack level down from the sequence where it's called.
  up:
    This moves the sequence stack down one level, overwrites the previously stored sequence at that level, and runs the called sequence:
      eg. 'up:somesequence' replaces the sequence at the next level up with the 'somesequence' sequence and runs it.
  top:
    This completely clears the sequence stack and runs the called sequence on a fresh stack.  It's equivalent to setting the stack to the same state as when Jester is originally invoked:
      eg. 'top:main' runs the main sequence on a completely fresh sequence stack.

As a general rule, it's best not to use any actions that deal with navigation (see 'help module navigation') or responding to user key presses (see 'help sequences keys') when you are on a sequence stack level other than the top.  You can try, but most likely it will just be a confusing mess.  ;)  Subsequences are ideally designed for non-user facing actions like loading data, or making a conditional decision, etc.]]

-- sequences -> arguments
jester.help_map.sequences.arguments = {}
jester.help_map.sequences.arguments.description_short = [[Passing arguments to sequences.]]
jester.help_map.sequences.arguments.description_long = [[Any code system that wants more flexibility supports arguments, and Jester sequenes are no different.  Arguments allow you to pass data to a sequence at the time it is called, and this data can then be used by the sequence.

Passing arguments to a sequence is simple -- just follow the sequence name with a space, then a comma-separated list of arguments.  In the interest of keeping the core small, Jester's argument parser is fairly simplistic, so you need to follow these rules when passing arguments:

  They can contain only alphanumeric characters and underscores.
  They must be separated by commas.
  There can be no space in the argument list.

eg. 'mysequence value1,value2,some_other_value'

See 'help sequences variables for how to access arguments in your sequences.]]

-- sequences -> storage
jester.help_map.sequences.storage = {}
jester.help_map.sequences.storage.description_short = [[Jester's storage system.]]
jester.help_map.sequences.storage.description_long = [[Jester provides a simple key/value storage mechanism  This allows you to store user input, load data from external sources for later use, keep track of how many times something was done, etc.

The storage is diveded into 'areas'.  Each area is capable of storing key/value pairs that are independent of other storage areas.

To learn how to access storage areas in sequences, see 'help sequences variables'.

To learn how to perform various operations on storage areas from a sequence, see 'help module core_actions'.]]

