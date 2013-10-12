# Unification

Unification provides the "selection" aspect of the [structured program theorem](https://en.wikipedia.org/wiki/Structured_program\
_theorem).  However some variations on unification provide selection but might also offer more power.

# Join and meet

[Join and meet](https://en.wikipedia.org/wiki/Join_and_meet) are mathematical relations.  A "lattice" has both relations.  Having just join makes a join-semilattice.  With the latter, you can have [LVars](http://composition.al/blog/2013/09/22/some-example-mvar-ivar-and-lvar-programs-in-haskell/).  Unification is one join operation.  Can Amalog provide join as the fundamental operation and have unification of first-order terms be the default join operation?  Users would be free to define their own join operation which is used when calling `=/2` on terms with a specific functor and arity.

# Scratch

Support both pre- and post-unification hooks.  Post-unification hooks are nearly identical to attributed variables in Prolog.  They allow unification to happen and then seek additional goals.  There should also be a way to seek additional goals immediately before attempting unification.  In both cases, variable bindings made in these goals are undone on backtracking.  Many use cases for pre-unification hooks can be emulated with post-unification hooks and a compound term wrapper.  Unfortunately, this is nearly the same as requiring a forcing function on futures and lazy values, which is ugly.  More importantly, a forcing function requires infectious changes to consumers when a library decide to lazify one of its return values.  A consumer should never have to change its code based on changes a library makes to internal implementation details.  Make sure that lazy goals (invoked only when needed) and parallel futures (work starts in parallel; blocks until value ready) can be implemented in terms of this underlying, post-unification hook mechanism.

Pre-unification hooks should only be run if we’re about to unify that specific variable, not a parent term.  For example if X has a pre-unify hook, it should not run during: foo(X) = bar(test).  That’s because unification fails on the compound term’s name before ever trying X=test.

