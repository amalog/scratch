I don’t yet have many opinions about how this should work.  However, it seems reasonable to use the foreign interface to implement many Amalog primitives.  For example, there will be some IO primitives.  These could be implemented via the foreign language interface rather than built into the language itself.  In some environments (scripting, browser) there’s no need for IO so a language implementer shouldn’t be required to support it.  Amalog just needs to define how the IO library behaves, if it’s implemented.  C took that route.

Look at Lua for inspiration.  I've heard numerous rumors that it has one of the best foreign language interfaces of any programming language.  Look at SWI-Prolog's foreign language interface for ideas that apply to logic programming.

Remember that the foreign language could be C or JavaScript or Haskell or Forth.  They each have different ideas of what a function is.  All of them should be acceptable.

It's probably also worth thinking about how Amalog can be embedded into a foreign language.  I hope that Amalog will be simple enough to implement that most languages will implement a native Amalog interpreter.  However, some users will eventually want to embed the very best/fastest/most-popular Amalog engine, so give it some thought.
