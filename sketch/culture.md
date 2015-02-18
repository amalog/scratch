# Culture

The culture surrounding a language is probably even more important than the technical features of the language.  Dozens of languages provide a good enough technical foundation.  Success depends on recruiting and retaining the best people.  That's done by a spirit of humility, acceptance and gratitude.

## Personal Preference Packages

Most programmers have strong preferences about certain programming patterns or the way certain things should be done.  Each developer's preferences matter a great deal to him, but may not be interesting to others.  Forcing him to live by the preferences of others is likely to alienate him and push him from the community.

One cultural practice to work around this is to encourage "personal preference packages".  I bundle up all my personal preferences into a package of predicates and macros that I like.  I use that package in all my work.  If others like it, they can use it too.  Over time, the community can adopt what works best.  So all my code starts with something like:

```
use "ndrix.org/mndrix"
```

The key is for the language to be flexible enough that these preferences can be expressed in a library.  For example, a Go developer may get tired of reading

```go
_, err := foo()
if err != nil {
    return err
}
```

Perhaps she wants to read something like this instead:

```go
_, "ok" := foo()
```

She should be able to write a library which converts what she wants into what the language requires internally.
