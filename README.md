Nothing to see here.

# Priorities

A prioritized list of design goals for Amalog. Top-level bullets are priorities. Secondary bullets are examples or clarifications.

* logic programming
* easy to implement
    * <5k lines of code
    * <50 page specification
* compiles to target language for deployment
    * at least: interpreter + embedded AST
    * ideally: idiomatic code
    * try to generate a procedure for each predicate mode
* interfaces (or [typeclasses](http://book.realworldhaskell.org/read/using-typeclasses.html) or [traits](http://scg.unibe.ch/research/traits/))
* easy to create tools
    * code formatting
    * static analysis
        * mode system
        * type system
    * code navigation
    * refactoring
    * syntax highlighting
* partial evaluation
* macros
  * closely related to refactoring tools

# Principles

## Progress

Don't halt a developer's forward progress for mistakes which can be resolved later.  Software development is a process of experimentation and discovery.  The flow of exploration should not be broken lightly.

Naively following this principle incurs substantial technical debt, whose future payment also halts progress.  Tools must make it easy for a developer to find and pay this debt when she's ready.

## Religion

If a style convention doesn't matter (less than 10% difference in productivity between choices), adopt one arbitrarily and make the others illegal.  The amount of productivity lost through argument and mixed conventions far outweighs any benefits.

Examples might include tabs vs spaces, line endings, indent size, identifier naming style, brace placement, if-else layout, etc.

## Experiment

Base language design decisions on the results of objective, repeated experiments whenever possible.  Give greater weight to experiments conducted in "real world" scenarios rather than micro-experiments that try to simulate one small aspect of software development.

## Performance

Don't worry about runtime performance.  Get the semantics and feel of the language right.  Nearly any useful language can be optimized later.
