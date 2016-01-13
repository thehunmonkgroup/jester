# A high-level introduction to the way Jester works

Jester is VoIP toolkit for FreeSWITCH written in Lua. The goal of Jester is to provide a standardized set of tools that allow you to accomplish most of the common tasks you'll face when putting together phone trees, voicemail systems, etc. And, if Jester can't do something you need, it's modular, extensible design allows you to easily add the functionality in a way that not only you but others can benefit from!


## Running Jester

Jester is designed to be executed as a standard Lua script from the FreeSWITCH dialplan. The general format is as follows:

```xml
<action
  application="lua"
  data="jester/jester.lua <profile> <sequence> [arg1],[arg2],...,[argN]"
/>
```


## Configuration system

Configurations are stored in three different places in Jester:

  1. jester/conf.lua - Global configuration
  2. profiles/[name]/conf.lua - Profile configuration
  3. modules/[name]/conf.lua - Module configuration

The global configuration file and the voicemail profile's configuration file are well commented, check them out for more details.

The main configuration gets loaded for all calls to Jester, while the profile configuration only gets loaded for the profile that Jester is currently running.

One important thing to note about these configurations is that any variables in them are only processed once, when Jester initially loads. If you have variables that change throughout the course of the call, you'll need to put them in storage or in channel variables.


## Brief Lua language tutorial

For a definitive explanation of the Lua language, the online [Lua manual](http://www.lua.org/manual/5.2) is the place to go:



This will be a very quick overview of the basics that you'll most likely use in sequences.

Lua is loosely typed, and will automatically convert types based on the operation you're trying to perform, eg. if you concatenate a string with an integer, the integer will be converted to a string.

**Define a variable:**

```lua
  -- Assign the 'name' variable an integer value of zero.
  name = 0
  -- Assign the 'name' variable the string value of "foo"
  name = "foo"
  -- Another way to Assign the 'name' variable the string value of "foo"
  name = [[foo]]
  -- Assign one variable to another
  name = value
```

Variable names can be any string of letters, digits and underscores, not beginning with a digit

**Math:**

```lua
  foo = foo + 1
  foo = foo - 1
  foo = foo * 1
  foo = foo / 1
```

**Relational operators:**

```lua
  == -- equal
  ~= -- not equal
  <  -- less than
  >  -- greater than
  <= -- less than or equal to
  >= -- greater than or equal to
```

These return false when what they compare is false or nil, all others return true.

**String concatenation:**

```lua
  newstring = oldstring .. "more"
```

**Conditional statements:**

```lua
  if foo ~= "yes" then
    -- Do something
  end
  if foo == 1 then
    -- Do some stuff
  elseif foo == "bar" then
    -- Do something else
  else
    -- Ok, do this
  end
```

**Boolean:**

```lua
  foo = true
  bar = false
```

**Non-value:**

```lua
  baz = nil
```

**Logical operators:**

```lua
  foo = true and false -- returns false
  foo = true and "bar" -- returns "bar"
  foo = false or true -- returns true
  foo = "foo" or "bar" returns "foo"
  foo = false or nil -- returns nil
  foo = true and "bar" or "baz" -- returns bar
  foo = false and "bar" or "baz" -- returns baz
```

**Tables:**

The only structured data in Lua. Table keys that are strings have the same restrictions as variable names (in the Jester world, anyways).

```lua
  -- Create an empty table.
  foo = {}
  -- Create an ordered list.
  table1 = {10, 20, 30}
  -- Create a record-style table, this is not ordered!
  table2 = {
    -- String table keys have the same restrictions as variable names
    bar = "baz",
    bang = "zoom",
  }
  value = table1[1] -- value is 10
  value = table2.bar -- value is "baz"
  complex = {
    {
      one = "two",
    },
    {
      three = "four",
    },
  }
  -- Value is two
  value = complex[1].one
```

