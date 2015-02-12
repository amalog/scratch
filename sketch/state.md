# Mutable Shared State

When state is both mutable and shared, even single-threaded programming [causes problems](https://groups.google.com/a/dartlang.org/forum/#!topic/misc/3wUeZvYQQFo/discussion) (that discussion thread has some great discussion about asynchronous programming primitives).  Here are a few lessons learned:

  * when a user says “foo should be explicit” what he really means is “I want an easy way to detect foo” (see Justin Fagnani’s comments about explicit `await`).  In my view, tooling is almost always better than explicit syntax.  Syntax is for conveying programmer intent.  Certainly a programmer doesn’t want to await anything.  He wants to use a value.  Awaiting is an extraneous implementation detail about which he only sometimes cares.  When he cares, he can run a tool to find out (via static analysis, profiling, etc).
  * it’s worth thinking about the interaction between async code and side effecting code. a tool should be able to statically detect when they occur together. it makes me think this is one more reason to avoid side effecting code as much as possible
  * programming is very subjective.  Justin says, “You could accidentally call an expensive blocking function inside a node-like context” but he doesn’t advocate for a keyword that marks computationally expensive operations or marks downstream calls to print().
  * explicit syntax is viral (see [Christopher Wright’s comment](https://groups.google.com/a/dartlang.org/d/msg/misc/3wUeZvYQQFo/4R2niR6y6SUJ)) because everyone up the call stack has to change his code to be explicit.  no such changes are required for implicit constructs.
  * mutable state is horrible, horrible stuff.  Look at Justin’s Dart example with explicit Futures and the questions he raises.  Each question is only a problem because `Greeter.message` is mutable

Prolog generally avoids mutable state entirely.  Unbound variables aren’t so much mutable as they are “doesn’t have a value yet”, just like lazy variables in Haskell.  Unfortunately, Prolog does have global, mutable flags.  Some Prolog programs also use the database as a global, mutable state storage facility.  Both of these problems need to be tamed somehow.

Many dynamic languages suffer from code as shared, mutable state.  I’ve seen both Perl and Prolog modules which behave differently depending on which other modules are loaded at run time.

Many Prolog implementations have way too much global state for configuration.  For example, SWI Prolog has `set_prolog_flag/2`, `portray_text/1`, `style_check/1`, etc.  If a clause wants to change `style_check` behavior locally, it has to figure out the current state, set it to a new state, restore the old state.  Of course doing any of that from inside a macro often requires much more effort.  One should be able to set these configuration items lexically.  Perl’s `no warnings` mechanism is helpful in this regard.


# State

Any Prolog variant should have something like Mercury's state variables to make variables `Foo0`, `Foo1`, `Foo2`, etc more palatable. They're kind of like pipes for data to flow through, so perhaps use a `|` character to denote them. They're also like automatically numbered variables using a base name, so a `#` character is also appropriate.  Mercury uses `!` to denote them (suggesting danger?).  Mercury's state variables work well in many cases. The only problem with them is that they impose an order on goals which prevents goals from being reordered (often requiring clauses that vary only in their goal order). I ran into this problem repeatedly while working on "tp".  It'd be cool to have two variants of state variables: one that imposes order and one that leaves the compiler free to reorder goals. It's like pipes that can flow in only one direction and pipes that can flow into multiple directions. That suggests `|` for one direction (only one line) and `#` for multiple directions (many lines).

It's often convenient to implicitly thread state variables through a predicate. DCG notation is the best known example. [Aquarius Prolog](http://www.info.ucl.ac.be/~pvr/aquarius.html) has [Extended DCG Notation](http://www.info.ucl.ac.be/~pvr/Peter.thesis/Peter.thesis.html) which allows one to thread multiple state variables through a predicate. In some sense, all Prolog predicates implicitly thread a database through the goals. It's the database against which they seek goals. Mercury performs IO by threading a "state of the world" through predicates that perform IO. Haskell monads are often used to make State threading implicit. The high level observation is that programmers don't like to perform bookkeeping on this state. Perhaps there can be a way for a predicate to declare "I need access to the following state: database, DCG and IO". The compiler  implicitly adds arguments to the predicate for that state. Some predicates only need to read the state. Others need to create new state. Some need to do both. I don't quite know how this will look, but it seems like a problem worth addressing.


# Implicit arguments

The following observations lead me to think about implicit arguments when working with state:

  * While reading *Pane, Ratanamahatana, Myers; "Studying the Language and Structure in Non-Programmers’ Solutions to Programming Problems"* I concluded that people prefer implicit arguments
  * DCG notation in Prolog (based on two implicit arguments)
  * Perl's `$_` variable (called "topic" or "it")
  * [Conditions](http://blog.ndrix.com/2013/02/programming-for-failure.html) allow error handling to be implicit

## Syntactic Benefits

The most obvious benefit of implicit arguments is reducing syntactic stutter.  Compare this example:

```perl
if ( -x $filename ) {
    say "executable";
}
elsif ( -f $filename ) {
    say "file";
}
elsif ( -d $filename ) {
    say "directory";
}
```

with this one:

```perl
given ($filename) {
    when(-x) { say "executable" }
    when(-f) { say "file" }
    when(-d) { say "directory" }
}
```

The second snippet avoids repeating `$filename` over and over. (Incidentally, when I typed these examples, I misspelled the variable name and I only had to correct it in one place in the second example).

In this example, the topic is strictly syntactic sugar.

## Bookkeeping Benefits

Implicit arguments can also save us the hassle of bookkeeping.  Compare this example:

```prolog
foo(A,Z) :-
    bar(A,B),
    baz(B,C),
    bar(C,Z).
```

with this one:

```prolog
foo -->
    bar,
    baz,
    bar.
```

The compiler takes care of naming all the intermediate variables and wiring them to each other correctly.  If I add a goal to the conjunction, the second example requires a single line change.  The first example requires a single line plus a bunch of variable renamings.

In this example, the topic is strictly syntactic sugar.

# Software Transactional Memory

When handling state across threads of control (concurrent or parallel), software transactional memory is a convenient abstraction.  The [cleanest STM implementation](http://research.microsoft.com/pubs/67418/2005-ppopp-composable.pdf) that I know of keeps a record of all variables that are read and written during a transaction.  Those assumptions are checked during commit.  The trail seems like a natural place to record that kind of information.  Although, if a predicate reads a variable, then backtracks to another choicepoint, the first variable needs to remain in the "read set".  That variable's value did impact execution.  If it has changed outside the transaction, we must retry.

This idea of logging all reads and writes gives rise to the cool `retry` mechanism in Haskell.  The computation is automatically postponed until one of the variables in the read set has changed.  That same mechanism might be usable for automatic goal suspension.  For example, a hypothetical `length/2` predicate:

```prolog
length(L,N) :-
    once( ground(N)
        ; proper_list(L)
        ; retry
        ),
    length_(L,0,N).

length_([],N,N).
length_([_|L],N0,N) :-
    succ(N0,N1),
    length_(L,N1,N).
```

# IO

Input and output are closely related to state. Mercury and Haskell handle them both with similar language primitives.  Haskell's strict separation of IO from other computations allows the type system to guarantee that a memory transaction (for example) can be retried without repeating IO side effects.

Unfortunately, Haskell's view is too strict.  The classic IO side effect is "launching missiles".  We don't want to relaunch the missiles if a memory transaction is retried.  Fortunately, not all IO is as dangerous as missiles.  Sometimes IO is just checking a clock or verifying a file's existence.

This hints at a distinction between read IO and write IO.  Missiles are clearly intended to "write" to the state of the world, modifying it for all future readers.  Checking a clock leaves no permanent trace that it happened.

Various synchronization primitives make this distinction.  For example, a [readers-writer lock](https://en.wikipedia.org/wiki/Readers%E2%80%93writer_lock) allows parallel reads but serializes writes.  An STM transaction that only checks a clock could be retried without harm.

Logic variables fit into this mix somehow.  Predicates like `var/1` or `ground/1` just read the values of a variable.  They never modify it.  Predicates like `=/2` may write a new value to the variable.

When considering execution order, reads can be swapped among themselves without changing the result.  However, reads may not swap places with a write.

In Mercury, each IO predicate takes two implicit variables:

  * state of the world as input
  * state of the world as output

Threading this state variable through the predicates imposes an order on the IO operations.  A predicate that reads the state of the world only needs the input.  For example,

```prolog
file_exists(File,World) :-
    ...

create_file(File,World0,World) :-
    ...

foo(File,World0,World) :-
    % execution order is interchangeable, as data flow suggests
    file_exists(File,World0),
    file_exists(foo,World0),
    file_exists(bar,World0),

    create_file(baz,World0,World).
```
