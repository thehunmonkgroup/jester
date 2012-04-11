 * Navigation stack probably doesn't work properly in inside any subsequences
 * DTMF in the global key handler is not queued --  keys that are pressed
   during actions that have no keys param are simply discarded.
 * Modules currently can't implement handlers for other modules -- need a way
   to tell the core how to load the module file providing the handler, but
   call the action from the file it's implemented in.
 * Path separators are all assumed to be *nix-style, which breaks on Windows.
