# Types

I want Amalog to have built in support (or conventions) for types, but not in the way that one thinks of statically typed languages.  Amalog should be dynamically typed but allow developers to indicate when their predicate only works with a subset of all possible values.


## Scheduling via Types

`length(list,int)` is a helpful description of the kinds of values that `length/2` works with.  If types are available, the compiler (or runtime) can make certain optimizations.  Consider:

```prolog
foo(A,B,C) :-
    append(A,B,C),
    length(A,N),
    length(B,N),
    length(C,TwoN),
    times(2,N,TwoN).
```

`length(_,N)` constrains `N` to the set of integers.  `times(_,N,_)` constrains `N` to the set of numbers.  The compiler can discern that the intersection of "the set of integers" and "the set of numbers" is "the set of integers".  It can augment the body's goals with `integer(N)`.  Type check predicates like `integer/1` are fast and deterministic.  By adding `integer(N)` to the body, the scheduler can choose it before more expensive goals and perhaps avoid some work.


## Partial Evalution via Types

Alternatively, the partial evaluator might be able to avoid some work entirely.  Consider a nonsensical predicate:

```prolog
foo(L,Y) :-
  length(L,N),
  x_codes(N,Y).

x_codes(A,Y) :-
  atom_codes(N,Y).
x_codes(A,Y) :-
  int_codes(A,Y).
```

The partial evaluator inlines the clauses of `x_codes/2` to get:

```prolog
foo(L,Y) :-
  length(L,N),
  ( atom_codes(N,Y)
  ; int_codes(N,Y)
  ).
```

We see that `length/2` requires that `N` be an integer and `atom_codes/2` requires that `N` be an atom.  The intersection of those types is empty, so the first disjunction can be replaced with `fail`.

```prolog
foo(L,Y) :-
  length(L,N),
  ( fail
  ; int_codes(N,Y)
  ).
```

Further simplification leads to:

```prolog
foo(L,Y) :-
  length(L,N),
  int_codes(N,Y).
```

So the type information has allowed us to remove a goal lookup and discard a choicepoint at compile time.
