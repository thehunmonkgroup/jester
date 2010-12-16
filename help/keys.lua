return [[
Jester provides high-level implementations for acting on keys pressed by the
user.

To maintain the simplicity of the engine, menu-type navigation is limited to
single digits.  Any action that has the 'keys' parameter supports responding
to key presses.  The layout of the keys parameter is as follows:

keys = {
  ["1"] = "somesequence arg1,arg2",
  ["2"] = ":someaction",
  ["3"] = ":break",
  ["*"] = ":navigation_up",
  invalid_sound = "ivr/ivr-that_was_an_invalid_entry.wav",
  invalid_sequence = "mysequence arg1,arg2"
}

The key itself is enclosed in square brackets and quotes.  The values for each
key can be in one of three forms:

 1. A sequence to run (with arguments if desired)
 2. An action to run directly (not common besides navigation)
 3. A special playback operator

Actions and playback operators are preceeded by a colon.

The playback operators are as follows:
 :break - Break playback or recording of a file
 :fastforward [milliseconds] - Fast forward through a playing file.  Replace
   [milliseconds] with the number of milliseconds to fast forward, Default is
   3 seconds.
 :rewind [milliseconds] - Rewind through a playing file.  Replace
   [milliseconds] with the number of milliseconds to rewind, Default is 3
   seconds.
 // TODO: is this true?
 :pause - Pause a playing file.  If the file is already paused, resume
   playback.
 :restart - Begin playback of a file from the beginning.
]]
