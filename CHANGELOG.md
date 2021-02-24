TODO: Update for 2.x
New in 2.0:
 * Sequence environment now has full access to most Lua globals: previously,
   sequences were loaded in a highly restricted environment, without access
   to almost all of Lua's functional libraries. This restriction has been
   removed, and almost all modules/functions available in the normal global
   Lua namespace are now accessible from within sequences.
 * jhelp and all command line documentation are replaced with ldoc generated
   HTML pages: Jester documentation was too inaccessible in its previously
   structured form. It can now be generated from ldoc, or accessed online at
   http://thehunmonkgroup.github.io/jester/doc/
 * format module action 'format_number' deprecated: use equivalent
   'format_string' action instead.
 * navigation module action 'add_to_stack' deprecated: use equivalent
   'navigation_add' action instead.
 * navigation module action 'navigation_up' deprecated: use equivalent
   'navigation_previous' action instead.
 * navigation module action 'navigation_top' deprecated: use equivalent
   'navigation_beginning' action instead.
 * tracker module, counter action, increment default behavior change:
   Previously, the default behavior of the tracker module's counter action
   when its 'increment' parameter was not set was to do no incrementing of
   the counter. The new default behavior is to increment by 1. The old default
   behavior can be acheived by setting 'increment' to 0.
 * Main module files now named init.lua: Previously, module naming convention
   for the main module file was 'modules/[name]/[name].lua'. This has been
   changed to the more standardized 'modules/[name]/init.lua'.
