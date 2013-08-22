Google has a tool, called Grok, for analyzing massive amounts of source code. [The video](http://vimeo.com/16069687) is worth watching again because it has some insights into programming languages as an art. Steve Yegge says that writing a parser is the smallest concern when doing code analysis. Writing tools that understand code is mostly an effort in data flow analysis, etc.  Although writing a parser isn't the biggest challenge when writing tools, it is the first challenge. Thus it presents a barrier to entry which many developers won't cross. Similarly, a complex syntax tree poses ongoing challenges for beginning analysts. They must account for and navigate every control construct. A minimal syntax with few control constructs makes it easier to get started and should result in many tools to address small analysis tasks.

Writing linters and local type inferencers and other such tools should be as easy as writing macros. The compiler should offer a hook which is run immediately after reading a term (for analyzing raw syntax) and another after all macro expansions are done (for analyzing the code that will actually run). Tools like SWI-Prolog's `style_check` then become extensible by the user and available for enforcing module- or project-local conventions. Libraries should be able to export analysis rules to warn their users if they're not following best practices.

There should exist a tool making it easy to traverse all code in a file or directory or repository.  For example, to rename all goals `foo/2` to `bar/2` and swap the arguments, I should only have to do this:

    catchy-command-name goal foo(A,B) bar(B,A)

Arbitrarily complex transformations should be just as easy.  For example, to replace hardcoded occurences of the numeric constant π, we might do:

    catchy-command-name -f replace_pi

where `replace_pi.ama` contains

    macro_expansion expression Pi π
        number Pi
        abs(Pi - π) < 0.001


It's really important that developers be able to quickly locate a predicate that can accomplish the task they want.  Haskell's hoogle tool is fantastic for this.  I search for `[a] -> Int` and the first result is `length :: [a] -> Int`.  I should be able to search for `+list -integer` and get back `length +List:list -Length:integer`.  The order of arguments shouldn't matter.  Types and modes should be strictly observed.
