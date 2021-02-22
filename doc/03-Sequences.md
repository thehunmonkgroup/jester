# Sequence tutorial

A sequence is a series of actions that are executed in a sequential order.

Sequences are the primary control mechanism for building workflows in Jester.


## Writing sequences

At its heart, a sequence is a Lua script. If you are familiar with Lua syntax, then writing sequences should be quite trivial. If you're new to Lua, check out @{01-Intro.md.Brief_Lua_language_tutorial} for a primer on the basic syntax that will be used in sequences.

A sequence is a list of 'actions' to take in a certain order, very similar to how commands would be executed sequentially in a dialplan extension.

The most simple sequence you can write illustrates its basic format:

```lua
  return
  {
    {
      action = "none",
    },
  }
```

This sequence calls the "none" action, which is just a passthrough. This is a sequence (the outer curly brackets), with one action (the second set of curly braces around the 'action' parameter). For more on how to write actions, see [Writing actions](#Writing_actions).

Here's a slightly more complex sequence:

```lua
  mailbox = variable("mailbox_number")
  record_location = storage("default", "where_to_record")

  return
  {
    {
      action = "play",
      file = "/var/voicemail/" .. mailbox_number .. "/greeting.wav",
    },
    {
      action = "record",
      location = record_location .. "/messages",
    },
  }
```

As you can see, sequences can contain variables. They can also use conditional statements and concatenate strings (in fact, they can actually do everything a Lua script can do, but that is beyond the scope of this tutorial). See [Accessing/using variables](#Accessing_using_variables) for more information on using variables in sequences, and [Advanced tricks](#Advanced_tricks) for more creative sequence designs.

The last example illustrates a basic design point of sequences. You can think of everything above the <code>return</code> keyword as a kind of scratch pad, where you can assemble the necessary variables and perform other tasks to prepare things to be used in the actual sequence -- and everything below the <code>return</code> keyword statement as the final sequence you give to Jester for executing.

One important thing to note is that Jester re-evaluates the entire sequence before each sequence action is run. In a practical sense this means that if you set a variable in action #1, that variable's value will be available in action #2. This is a very useful feature!  On the down side, this also means that Jester core has to do a lot of evaluating, which could have an impact on high load systems. For this reason it is recommended that if you're going to use any channel variables or storage items more than once in your sequence, you should define a variable for them in the top section, and use that variable when writing actions.

For an easy way to generate templates for sequences, see the @{04-Scripts.md.jsequence} documentation.


## Writing actions

Actions are the mechanism for doing something in a sequence. They are configurable templates that allow you to pass a command with options to Jester, which are then passed on to the module providing the action for execution. Put simply, you give the module a few simple instructions, and it handles the dirty work of accomplishing the job through the FreeSWITCH/Lua API.

Each action is a Lua table within the main sequence. The table is a series of key/value pairs (called parameters from here out) that contain the action instructions. Here's an example of the <code>play</code> action, which plays a sound file on the channel:

```lua
  {
    action = "play",
    file = "/tmp/mysoundfile.wav",
    keys = {
      ["#"] = ":break",
    },
    repetitions = 2,
    wait = 3000,
  },
```

An action always has at least one required parameter, <code>action</code>, which is the action to execute. The other parameters are dependant on the action being taken, see the various module documentation for detailed help on a particular action, including the parameters it accepts.

For more information on overall sequence design, see [Writing sequences](#Writing_sequences).

To learn about Lua tables, see @{01-Intro.md.Brief_Lua_language_tutorial}.

For an easy way to generate templates for actions, see the the @{04-Scripts.md.jsequence} documentation.


## Accessing/using variables

Variables in sequences are standard Lua variable definitions:

```lua
  name = value
```

See @{01-Intro.md.Brief_Lua_language_tutorial} for more examples of defining variables.

You can assign variables to other variables you create in the sequence itself, and to the set of outside variables detailed below. Note that for any new variable you create in the sequence, you should always initialize it to some value (or to an empty string) before attempting to use it.

To avoid namespace collisions in your sequence, the following variable names are prohibited:

 * core *(access to Jester core functions, usually not needed)*
 * global
 * profile
 * args
 * variable
 * storage
 * debug_dump

Sequences can access outside variables from five places:

 * **Global configuration:**
   Variables defined in <code>jester/conf.lua</code> can be accessed through the <code>global</code> namespace, eg.
    foo = global.base_dir
   Accesses the <code>base_dir</code> variable from the global configuration.
 * **Profile configuration:**
   Variables defined in the running profile's <code>conf.lua</code> can be accessed through the <code>profile</code> namespace, eg.
    foo = profile.mailbox_dir
   Accesses the <code>mailbox_dir</code> variable from the profile configuration.
 * **Channel variables:**
   Variables defined in the current FreeSWITCH channel that Jester is running in can be accessed through the <code>variable()</code> function, eg.
    foo = variable("caller_id_name")
   Accesses the <code>caller\_id\_name</code> variable from the channel.
 * **Jester's internal storage system:**
   Variables defined in Jester's internal storage can be accessed through the <code>storage()</code> function, eg.
    foo = storage("mailbox_settings", "mailbox")
   Accesses the value of the <code>mailbox</code> key from the <code>mailbox\_settings<code> storage area. See [Storage system](#Storage_system) to learn more.
 * **Sequence arguments:**
   Sequences can be called with arguments (see [Passing arguments](#Passing_arguments)), and these can be accessed through the <code>args()</code> function, eg.
    foo = args(1)
   Accesses the first argument passed to the sequence. See [Passing arguments](#Passing_arguments) for more information.


## Storage system

Jester provides a simple key/value storage mechanism. This allows you to store user input, load data from external sources for later use, keep track of how many times something was done, etc.

The storage is divided into 'areas'. Each area stores key/value pairs that are independent of other storage areas.

To learn how to access storage areas in sequences, see [Accessing/using variables](#Accessing_using_variables).

To learn how to perform various operations on storage areas from a sequence, see the @{core_actions} module.


## Capturing user key input

Jester provides high-level implementations for acting on keys pressed by the user.

To maintain the simplicity of the engine, menu-type navigation is limited to single digits. Any action that has the <code>keys</code> parameter supports responding to key presses. The layout of the keys parameter is as follows:

```lua
  keys = {
    ["1"] = "somesequence",
    ["2"] = "someothersequence arg1,arg2",
    ["3"] = "@someaction",
    ["4"] = ":break",
    ["5"] = ":seek:+2000",
    ["6"] = ":seek:-2000",
    ["7"] = ":pause",
    ["*"] = "@navigation_previous",
    invalid = true,
    invalid_sound = "ivr/ivr-that_was_an_invalid_entry.wav",
    invalid_sequence = "mysequence arg1,arg2",
  }
```

The key itself is enclosed in square brackets and quotes. The values for each key can be in one of these forms:

  1. A sequence to run (with arguments if desired)
  2. An action to run directly (not common besides navigation)
  3. A special playback operator

Sequences are called in the same format as they are anywhere else in Jester. When a sequence is called, the key press is registered as valid, playback of the file is stopped, the currently running action is terminated, and the new sequence is called.

Actions are preceded by the @ symbol.

Actions run this way are run in 'ad hoc' mode -- they can accept no key presses, and the previously running action will be returned to if the ad hoc action does not call a new sequence. The @{navigation} actions are the most likely actions to be run in this form.

Playback operators are preceeded by a colon.

The common playback operators are as follows:

 * **:break** --
   Break playback or recording of a file
 * **:seek:+[milliseconds]** --
   Fast forward through a playing file. Replace [milliseconds] with the number of milliseconds to fast forward.
 * **:seek:-[milliseconds]** --
   Rewind through a playing file. Replace [milliseconds] with the number of milliseconds to rewind.
 * **:seek:0** --
   Begin playback of a file from the beginning.
 * **:pause** --
   Pause a playing file. If the file is already paused, resume playback.

There are other operators, check the Lua scripts in the FreeSWITCH source for more.

There are three extra parameters besides the keys that can be used to control how invalid key presses are handled. The default, if none of these are present, is to simply ignore the key press:

 * **invalid** --
   Set this to true if you just want to register the key press as invalid and break the currently running action.
 * **invalid_sound** --
   Set this to a file or phrase to play to the user after registering the key press as invalid and stopping playback of the file. The format of the filepath is the same as the ones accepted by the @{play} module.
 * **invalid_sequence** --
   Set this to a sequence to call after registering the key press as invalid and stopping playback of the file.

The <code>keys</code> parameter can be put in one of two places:

**As an action parameter:**

This sets the key mapping for just the action that it's defined in, eg.

```lua
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
```
In this case, once the action is complete, the mapping is cleared.

**As a sequence parameter:**

This sets the key mapping for all actions in the sequence, eg.

```lua
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
```
In this case, once the sequence is complete, the mapping is cleared. Note that individual actions in the sequence can still provide their own key mappings, and they will override the sequence mapping for that action.


## Passing arguments

Any code system that wants more flexibility supports arguments, and Jester sequenes are no different. Arguments allow you to pass data to a sequence at the time it is called, and this data can then be used by the sequence.

Passing arguments to a sequence is simple -- just follow the sequence name with a space, then a comma-separated list of arguments. In the interest of keeping the core small, Jester's argument parser is fairly simplistic, so you need to follow these rules when passing arguments:

 * The arguments themselves can contain no commas.
 * The arguments must be separated by commas.
 * There can be no space in the argument list.

eg.
    {
      action = "call_sequence",
      sequence = "mysequence value1,value2,some_other_value,1.2.3.4",
    }

See [Accessing/using variables](#Accessing_using_variables) for how to access arguments in your sequences.


## Simple decision making

At certain points in a sequence, you may want to take different actions based on the value of some channel variable or storage item. Jester provides a simple mechanism to do this, the @{core_actions.conditional|conditional} action.

It allows you to compare one value with another using various comparison strategies, and call a new sequence based on if the comparison is true or false. An example conditonal would be:

```lua
  {
    action = "conditional",
    value = number_of_messages,
    compare_to = 0,
    comparison = "equal",
    if_true = "exit",
    if_false = "play_messages",
  },
```

See the @{core_actions.conditional|conditional} action for more details.


## Subroutines

At certain points in a sequence, it may be desirable to fire off another sequence, and when it completes have Jester return to the previously running sequence. Subsequences allow you to accomplish this.

Jester's basic logic is to run one sequence and then exit. It will only run other sequences if you specifically tell it to. Normally, when you call one sequence from another, the original sequence is forgotten and the new sequence is run -- i.e., only one sequence at a time runs.

To allow you to run more than one sequence at a time, Jester keeps a 'sequence stack'. It runs sequences at a stack level until no more are called, then it checks to see if there's another level above it. If so, it returns to that level and continues running the sequence at that level, and so on until finally there are no more stack levels and Jester exits.

To operate on the sequence stack, you prefix calls to a sequence with one of three commands:

 * **sub:** --
   This moves the sequence stack down one level, and runs the called sequence there, remembering which action the current sequence is running. When the lower level stack finishes, the stack level is discarded, Jester moves up one level in the sequence stack, and continues with the next action in the seqeunce at that level, eg.
    {
      action = "call_sequence",
      sequence = "sub:mysubsequence",
    }
   calls the <code>mysubsequence</code> sequence in the next stack level down from the sequence where it's called.
 * **up:** --
   This moves the sequence stack up one level, overwrites the previously stored sequence at that level, and runs the called sequence, eg.
    {
      action = "call_sequence",
      sequence = "up:somesequence",
    }
   replaces the sequence at the next level up with the <code>somesequence</code> sequence and runs it.
 * **top:** --
   This completely clears the sequence stack and runs the called sequence on a fresh stack. It's equivalent to setting the stack to the same state as when Jester is originally invoked, eg.
    {
      action = "call_sequence",
      sequence = "top:main",
    }
   runs the <code>main</code> sequence on a completely fresh sequence stack.

As a general rule, it's best not to use any actions that deal with navigation (see the @{navigation} module) or responding to user key presses (see [Capturing user key input](#Capturing_user_key_input)) when you are on a sequence stack level other than the top. You can try, but most likely it will just be a confusing mess. ;)  Subsequences are ideally designed for non-user facing actions like loading data, or making a conditional decision, etc.


## IVR/phone tree functionality

Through the @{navigation} module, Jester provides the necessary facilities to implement phone menus in sequences.

To provide a phone menu, it's necessary to track where a user has been. The navigation path serves this purpose. By adding a sequence to the navigation path, you can later return to that sequence by going up the path, or to the beginning of the phone tree by going to the beginning of the path.

One important thing to note is that you can't add the same sequence with the same arguments to the navigation path in adjacent positions -- this is an internal restriction to ease the implementation of the navigation path, and it wouldn't be sensible to do it anyways... ;)

See the @{navigation} module for more information on using navigation paths.


## Phrase macros

You are encouraged to use FreeSWITCH's phrase macro functionality when designing sequences. Doing so creates a nice logical separation between the kind of thing you want to play, and the actual process of playing the sound files. For example, if you use only phrase macros in your sequences for system prompts, then switching languages or voices becomes trivial.

All of the actions related to playback in Jester support using phrase macros, either directly, or by prefixing the macro name with 'phrase:', eg.

```lua
  {
    action = "play",
    file = "phrase:some_configured_phrase_macro",
  },
```

See the @{play} module for most of the playback-related functionality in Jester.


## Triggering actions on hangup/exit

Sometimes you need to make sure a sequence is run regardless if the user hangs up the call, or otherwise leaves the Jester environment.

Jester accomodates this by providing two places where you can register sequences to run at a later time:

 * **On hangup:** --
   See the @{hangup.hangup_sequence|hangup_sequence} action
 * **After the last active sequence ends:**
   See the @{core_actions.exit_sequence|exit_sequence} action


## Debugging

Sometimes as you're designing a sequence, it's either crashing Jester or not behaving as you would expect, and you can't easily figure out why. Jester provides a few debugging utilities to aid your investigative efforts:

 * **Turn on Jester's debug output:** --
   This can be done globally by setting the <code>debug</code> variable to true in <code>jester/conf.lua</code>, or per profile by setting the same variable in the profile. Turning this on outputs a massive amount of debugging information, pretty much detailing every single thing Jester is doing as it runs. You can further control what debugging information is output by changing the values (not the keys) in the <code>debug\_output</code> table in <code>jester/conf.lua</code> -- true turns on debugging output for that area, false turns it off.

 * **Use the debug dump functionality in your sequence:** --
   Jester exposes its core variable dumping function <code>debug\_dump()</code> to all sequences. You can place it in the top section of any sequence, give it a variable name, and it will dump the variable to the FreeSWITCH console. For example, to debug the <code>foo</code> variable:
    debug_dump(foo)
<br />

Syntax errors can be hard to debug. If you have one in your sequence Jester will most assuredly crash, and you can check the FreeSWITCH console for the error message. Usually it contains some helpful information pointing you to a line number and a suggestion what the problem might be. The most common mistakes are:

 * Missing a closing curly brace on the sequence, an action, or an action parameter.
 * Missing a comma at the end of a parameter or an action.
 * Trying to concatenate something that has no value.
 * Using '=' in a conditional when you meant '=='.


## Advanced tricks

Here are a few tricks that evolved as the default profile was written. They should start to open your mind as to what else is possible to do when designing sequences.

**Complex conditionals:**

If you want to use a conditional action to make a decision, but your condition is more complex than a single comparision, use native Lua conditionals to do the harder work, store the answer in a variable, and use that in the conditional:

```lua
  -- Complex message count.
  if number_of_messages > 0 and number_of_messages < 100 then
    access = "yes"
  else
    access = "no"
  end

  return
  {
    {
      action = "conditional",
      value = access,
      compare_to = "yes",
      comparison = "equal",
      if_true = "access_messages",
      if_false = "mailbox_full",
    },
  }
```

**Conditional keys in the key map:**

If the key map for an action depends on the state of certain variables, create a temporary key map variable containing the key map with constant key presses, use Lua conditionals to optionally add the other keys, then use the finalized key map variable as the value of the <code>keys</code> parameter:

```lua
  -- Add a key to the map conditionally.
  temp_keys = {
    ["3"] = "advanced_options",
    ["5"] = "repeat_message",
    ["9"] = "save_message",
    ["*"] = "help_exit",
  }

  if current_message ~= 1 then
    temp_keys["4"] = "prev_message"
  end
  if current_message ~= last_message then
    temp_keys["6"] = "next_message"
  end

  return
  {
    {
      action = "play",
      file = "myfile",
      keys = temp_keys,
    },
  }
```

