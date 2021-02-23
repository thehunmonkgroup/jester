# Jester

## Deprecated branch -- 1.x

**NOTE: This branch is no longer in development. The 2.x version of Jester has been converted into a suite of libraries, and all of the templating logic has been removed.**

## Introduction
Jester is a scripting toolkit for [FreeSWITCH](https://freeswitch.org) written in the [Lua](http://www.lua.org) programming language. It's functionality sits squarely between the feature set of the XML dialplan, IVR menus, and custom scripting. The goal of Jester is to ease development of voice workflows by providing a simple, unified way to implement more complex features that normally require custom scripting.

## Installation
See [INSTALL.md](INSTALL.md) for installation instructions.

## Architecture
Jester is written to be small, simple, and extensible. The core code is less than 800 lines! Most user tasks are carried out by pluggable modules, and people familiar with Lua scripting will find it easy to add new modules to extend functionality further. End users are spared the complexity of writing full scripts, and instead work inside script-like templates called 'sequences', that allow them to pass commands with parameters to the underlying modules, which handle all the dirty work.

## Comedian mail replica
Jester's default profile is a replica of [Asterisk's Comedian Mail](http://www.voip-info.org/wiki/index.php?page_id=502) system. The implementation is acheived using fourteen modules containing thirty-four distinct configurable 'actions', all re-usable for other complex voice workflows. Those transitioning from Asterisk to FreeSWITCH with concerns about the differences between the two voicemail systems can leverage this to provide a seamless transition to their end users.

## Documentation

Jester comes with extensive documentation available [online](http://thehunmonkgroup.github.io/jester/doc/), which should make it easy for new users and developers to get up to speed.

Once you've installed Jester, the next best step is to read the help. If you'd like to install it locally, install [LDoc](https://github.com/stevedonovan/LDoc), then run the following from the root directory:

```sh
  ldoc .
```

## Support

The issue tracker for this project is provided to file bug reports, feature requests, and project tasks -- support requests are not accepted via the issue tracker. For all support-related issues, including configuration, usage, and training, consider hiring a competent consultant.

## Other stuff
See [LICENSE.txt](LICENSE.txt) to view the license for this software.

See [BUGS.md](BUGS.md) for a list of known issues.

See [TODO.md](TODO.md) for a list of things we're working on.

See [CHANGELOG.md](CHANGELOG.md) for a running list of important changes.
