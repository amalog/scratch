Continuations are a powerful, fundamental construct which a language itself must support.  Using continuations, one can implement features such as [coroutines, exception handling, return statement, generators](https://en.wikipedia.org/wiki/Continuation#Uses) and backtracking (if Amalog didn’t have that natively).

It’s probably worth spending some time working with continuations in Scheme to get a feel for how they work and what they can do.

Implementing continuations in Golog would be very easy.  A continuation is essentially a snapshot of the entire machine.  Calling a continuation replaces the current machine with the snapshot.  Keep in mind the [continuation sandwich](https://en.wikipedia.org/wiki/Continuation#First-class_continuations) which suggests that some data (side effects only?) are preserved upon executing a continuation.

It seems reasonable for Amalog to have re-invocable, delimited continuations since they’re the most general form.  Although, maybe being delimited adds too much complexity for little gain.

Continuations are dangerous like GOTO, so the mechanism should have an obnoxiously long name like current_continuation/1 to discourage its use outside of library building block code.


## BinProlog

I get the sense that hidden inside BinProlog's implementation are interesting ideas about continuations.  In [BinProlog](https://code.google.com/p/binprolog/), during compilation, each clause is converted to "Continuation Passing Binary Clauses" with a single head and a single goal.  The final argument of each goal is its continuation.  For example,

    foo(X) :-
        writeln(X),
        writeln(middle),
        writeln(bye).

becomes

    foo(X,Cont) :-
        writeln(X,writeln(middle,writeln(bye,Cont))).

By defining `Head ::- Body`, clauses can access the continuation directly.
