return [[
USAGE:

From the dialplan:
<action application="lua" data="jester.lua <profile> <sequence> [arg1],[arg2],...,[argN]"/>

From the shell (from the directory jester.lua resides in):
lua jester.lua help [topic] [subtopic]
lua jester.lua <profile> help [topic] [subtopic]

From FreeSWITCH CLI:
luarun jester.lua help [topic] [subtopic]
luarun jester.lua <profile> help [topic] [subtopic]

TOPICS:
  intro:
    A high-level introduction to the way Jester works.
  sequence:
    How to build voice workflows with sequences
  modules:
    General information on the modular structure of Jester
  module [name]:
    Information on the installed modules.
  profile:
    High-level configuration for sequences.
  config:
    Basic overview of how Jester is configured
  keys:
    Introduction on how to capture user key input
  actions:
    Brief overview of how actions work.
  action [name]:
    Information on the installed actions.
]]
