# Jester

**IMPORTANT: The master/2.x branch of Jester is under heavy development, and not guaranteed to work, or show accurate documentation. You may use the [1.x branch](https://github.com/thehunmonkgroup/jester/tree/v1.x) if you need stable functionality, just know that it is unsupported.**

## Introduction
Jester is a scripting toolkit for [FreeSWITCH](https://freeswitch.org) written in the [Lua](http://www.lua.org) programming language.

It is a collection of libraries and convenience functions built and tested by a developer experienced in both FreeSWITCH and Lua.

The goal of Jester is to ease development of voice workflows by providing a simple, unified way to implement more complex features that normally require complex custom scripting.

## Installation
See [INSTALL.md](INSTALL.md) for installation instructions.

## Architecture
Jester is written to be small, simple, and extensible.

Most functionality is carried out by pluggable modules, and people familiar with Lua scripting will find it easy to add new modules to extend functionality further.

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
