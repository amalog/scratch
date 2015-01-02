# Modes

In logic programming languages, a "mode" is a pattern of inputs and outputs for a predicate.  They're intimately tied to a predicate's determinism.  For example, Prolog's `append/3` supports the following modes (using traditional Prolog mode syntax):

  1. append(+, +, -) is det
  1. append(+, +, +) is semidet (implied by rule #1)
  1. append(+, -, +) is semidet
  1. append(-, +, +) is semidet (but leaves a trailing, false choicepoint)
  1. append(-, -, +) is multi

These modes provide helpful documentation for developers ("how am I supposed to call this predicate?").  They also help the runtime (or compiler) know when a goal's proof must be delayed.  For example, `append(X,Y,Z)` cannot make progress until we bind one of the variables.

The determinism information also helps the runtime (or compiler) schedule proof execution.  Consider the following code:

```prolog
foo(A,B,C) :-
    append(A,B,C),
    length(A,N),
    length(B,N),
    length(C,TwoN),
    times(2,N,TwoN).
```

If we try to prove foo in the mode `foo(-,-,+)`, Prolog would execute `append(-,-,+)` to generate solutions whose accuracy is tested by subsequent predicates.  This performs lots of unnecessary backtracking.  Instead, we notice that both `append(-,-,+) is multi` and `length(+,-) is det` are available for proof right away.  The runtime would perform less backtracking if it proved `length(C,TwoN)` first.  At that point, `TwoN` is known and other goals become available for proof.  Eventually, we end up executing `append(+,+,+) is det` which should be more efficient.

Amalog should have a way to (optionally) describe the modes in which a predicate can operate.  The rest of this document is speculation on what that language might be.

## plus/3

Prolog has the predicate `plus/3` which defines the mathematical addition operation on integers.  One might be inclined to say that it supports the following modes:

  * plus(+,+,-) is det
  * plus(+,-,+) is det
  * plus(-,+,+) is det

That's partly true.  However, imagine the goal `plus(X,X,4)`.  It has mode `plus(-,-,+)` but it has the obvious, single solution `X=2`.  Similarly `plus(X,X,X)` has mode `plus(-,-,-)` but has the solution `X=0`.

The true mode rule for plus is "I can make progress if my arguments contain one or fewer unknowns".  In Prolog, we might define that rule as:

```
mode(Plus,det) :-
    Plus = plus(_,_,_),
    term_variables(Plus, Vars),
    length(Vars, N),
    once(N=0;N=1).
```

In other words, given a goal head, `mode/2` calculates that goal's determinism.  Failure means that the goal cannot progress under these conditions.
