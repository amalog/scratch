# Unification

Unification provides the "selection" aspect of the [structured program theorem](https://en.wikipedia.org/wiki/Structured_program\
_theorem).  However some variations on unification provide selection but might also offer more power.

# Join and meet

[Join and meet](https://en.wikipedia.org/wiki/Join_and_meet) are binary operators.  A "lattice" supports both operators.  Having just join makes a join-semilattice.  With the latter, you can have [LVars](http://composition.al/blog/2013/09/22/some-example-mvar-ivar-and-lvar-programs-in-haskell/).  Unification is one possible join operation.  Can Amalog provide join as the fundamental operation and have unification of first-order terms be the default?  Users would be free to define their own join operation which is used when calling `=/2` on terms with a specific functor and arity.

If join is defined as syntactic unification of first-order terms, then meet is naturally defined as anti-unification.

# Unification with Difference Lists

The difference list is a powerful data structure in Prolog.  I might have `X = [a,b,|T]`.  `X` represents a specific, grounded list.  However, I don't yet know exactly what the tail is.  One can think of `T` as a lazy representation of the list's tail.  I can append to this list as much as I want.  Conceptually `X` is immutable, but only partially known.

It's a powerful idea to incrementally build a partially known, immutable data structure.  It seems like there should be a way to generalize this feature to arbitrary data structures.

# Unification with Maps

Associative arrays in Prolog are typically stored as a list of `=/2` pairs from key to value.

I might have `X = [a=1,b=2]` and `Y = [b=2,a=1]`.  In a standard map, key order is not preserved so these two terms have identical semantics.  However, unifying `X` and `Y` fails because they're not structurally identical.

A slightly more complicated use case: We might have `[a=1,b=2]`.  Now I want to unify `[b=B]` with it.  Ideally I want `B=2` when finished.  Of course, standard unification fails because the terms differ in structure.  Instead I'd have to unify with `[_,b=B|_]`.  Of course that doesn't work if `a` and `b` keys change places in the list.

It seems like an operation slightly more general than unification could allow all the power of unification but also handle these use cases.  Perhaps we can allow one to add extra clauses to `=/2` to provide custom unification.  One could define a map structure as `map([a=1,b=2])` and then define `map(...) = map(...) :- ...` to customize how unification is handled for `map/2` terms.

We might also imagine a join operation for maps which performs set union on the keys and unifies (or recursively joins) values where the key is identical.  Using `v` for join (standard notation):

```prolog
?- X = [a=1,b=2],
|  Y = [b=B],
|  X v Y.
X = [a=1,b=2],
Y = [a=1,b=2],
B = 2.
```

This doesn't provide deterministic concurrency (as LVars do), but seems like a useful generalization or extension of unification.

# Variable Hooks

The ideas above describe how values are unified or joined together.  Hooks pertain to a variable and what happens when values are stored in them.

Post-unification hooks are nearly identical to attributed variables in Prolog.  They allow unification to happen and then to seek additional goals.  There should also be a way to seek additional goals immediately before attempting unification (pre-unification hooks).  In both cases, variable bindings made in these goals are undone on backtracking.

Many use cases for pre-unification hooks can be emulated with post-unification hooks and a compound term wrapper.  Unfortunately, this is nearly the same as requiring a forcing function on futures and lazy values, which is ugly.  More importantly, a forcing function requires infectious changes to consumers when a library decides to lazify one of its return values.  A consumer should never have to change its code based on changes a library makes to internal implementation details.

Make sure that lazy goals (invoked only when needed) and parallel futures (work starts in parallel; on read, blocks until value ready) can be implemented in terms of this underlying, pre-unification hook mechanism.  Make sure that true LVars (like "Freeze After Writing") can also be implemented with pre- and post-unification hooks.

Pre-unification hooks should only be run if we’re about to unify that specific variable, not a parent term.  For example if `X` has a pre-unify hook, it should not run during: `foo(X) = bar(test)`.  That’s because unification fails on the compound term’s name before ever trying `X=test`.
