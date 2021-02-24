## System requirements

 * Most recent Jester code
 * FreeSWITCH 1.0.7 or later
 * Lua 5.1 or later.
 * LuaSocket 2.0.2 or later
 * LuaFilesystem 1.4.2 or later
 * For data module support:
    * Any database that supports standard SQL queries. A recent version of
      MySQL, Postgres, or SQLite should work just fine.
    * ODBC and the ODBC driver for the above database.
 * For email module support:
    * A mailserver with an open socket that you can send messages through.
 * For Jester's event listener support via socket.lua (experimental):
    * A mod_event_socket connection to the FreeSWITCH server.
 * *Note that some other core modules have other dependencies, these are
    documented in the main description for each particular module.*


## Installation

Jester is relatively easy to install, especially if you have a modern package-based Linux distribution.  Here are the basic steps:

1. Install Lua (should be readily available from your packaging system)
   eg. ```yum install lua``` or ```apt-get install lua5.2```

2. Install the [LuaFileSystem](http://keplerproject.github.com/luafilesystem)
   and [LuaSocket](http://w3.impa.br/~diego/software/luasocket) packages (also
   probably available in your packaging system, they're in the EPEL repository for
   RHEL/CentOS/Fedora, and in the Debian repos as well. eg.
   ```yum install lua-filesystem lua-socket``` or ```apt-get install
   lua-filesystem lua-socket```
   If you can't find these in a package, you can use the
   [LuaRocks](http://luarocks.org) package manager, or install from source:

3. Set your LUA_PATH environment variable to include the FreeSWITCH 'scripts'
   directory.  This is for easy access when you are logged in at the command
   line.  For the bash shell, in a typical installation, it would look like
   this:
    ```
     export LUA_PATH=";;/usr/local/freeswitch/scripts/?.lua"
    ```


   The two semicolons at the beginning of the path are not a typo!  Lua
   interprets those as 'include my default paths too'.

4. Drop the entire 'jester' directory inside the FreeSWITCH 'scripts'
   directory.  In a typical installation, it would be at:

    ```
      /usr/local/freeswitch/scripts/jester
    ```



5. Depending on where you install the packages from step 2, you may need to
   fiddle with the LUA_PATH and LUA_CPATH settings in the lua.conf.xml file
   found in the ```conf/autoload_configs``` directory of your FreeSWITCH
   installation.
   If you're seeing errors at the FreeSWITCH console about not being able
   load "lfs" or "socket", then this is the most likely cause.
   For example, the configuration for LUA_CPATH should be somewhat like this:


    ```xml
      <param name="module-directory" value="/usr/lib64/lua/5.2/?.so"/>
    ```
   or

    ```xml
      <param name="module-directory" value="/usr/lib/lua/5.2/?.so"/>
    ```



6. If your FreeSWITCH 'scripts' directory is in a non-standard location, edit
   the value of the ```jester_dir``` variable in ```jester/conf.lua```
   appropriately.

7. Jester is now installed.


#### Note to Windows users:

  Jester won't work on Windows unless you figure out the path separator
  issue, as Jester assumes that paths are ```/path/to/blah```, and not
  ```C:\\path\to\blah```.  If you can solve that, it *should* work.
