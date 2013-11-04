# First Class Database

Databases are one of the defining features of Prolog variants.  Part of their utility comes from the way that Prolog code succinctly queries and infers from them.  Databases should be first class objects to make it easy to create, modify, garbage collect and query them.  As with all other Amalog values, they should be immutable.

## HTTP Requests

*I'm not so sure about this example anymore*

For example, in an HTTP request we’d like to verify a positive integer parameter named “count” with code like this:

    count_ok Count
	    count CountStr  // get the raw parameter value
	    phrase integer(Count) CountStr
	    Count > 0

This assumes that `count/1` unifies with the HTTP request parameter named “count”.  In other words, the HTTP request parameters are translated into an Amalog database.  The code calling `count_ok/1` might look like this:

    empty_db Req0
    assertz count(“123”) Req0 Req
    Req:count_ok Count

The goal `count_ok/1` is called as if its code were present in the `Req` database.

## Instead of Hash Tables

A first class database can fill the niche of a built-in hash table.  For example:

    % build nicknames database
    new_db Nicks0   // do we want sugar? Nicks0={}
    Nicks0:assertz [jacob(jake),william(bill),robert(bob)] Nicks

    % perform a lookup
    Nicks:william(NickName)

Of course, people are free to build hash table libraries if first class databases don't work out for that use case.

## Interface

By default, a database starts with these predicates in it.  They're how one interacts with a database.

  * `asserta(+Clause, -Db)` adds `Clause` to the front to create a new `Db`.  `Clause` can be a list to assert many clauses at once
  * `assertz(+Clause, -Db)` like `asserta/2` but adds to the end
  * `clause(-Node, -Ref)` iterates each database clause that unifies with `Node`. `Ref` is a reference to that specific clause in the database
  * `retract(+Node, -Db)` removes clauses that unify with `Node` (which can also be a clause ref from `clause/2`
  
In some circumstances (sandboxing?), one might want to remove these predicates or start with a different default set.  That should be easily done.

## Notation

Programmers need notation for constructing a database as a value.  One approach is to provide predicates which define an interface and require that developers manually construct a database using those predicates.  We need predicates for interacting with databases anyway, so this is the minimal notation approach.  Many languages stop here.

Will first class databases be used often enough to warrant syntactic sugar?  Sugar should be implemented with macros, so it won't be part of the core language.  Nevertheless, it's worth considering how this sugar might look.

One approach is to embed Amalog in Amalog using raw text syntax and have macros desugar it to a series of `assertz/2` calls.  Like this:

    Nicks = db`
        jacob jake
        
        william bill
        
        robert bob
    `
    Nicks:william Bill
    
Amalog's requirement for whitespace between predicates makes this syntactically expensive.  That overhead creates a barrier to entry to prevent them from using databases even when they make sense.  Using raw string syntax also hides the internal terms from macro expansion.  Without using it in real code, it's hard to say if that's what we want by default or not.

Databases are somewhat-sorta-kinda like associative arrays in other languages.  Languages divide into two categories on the sugar they use: `{}` or `[]`.  The latter case is most common in languages where all arrays are associative.  Semantically, a database is an indexed list of terms.  That suggests a `[]` notation.  `{}` is quite helpful for escape syntax inside DCGs, so I lean away from using that.  Perhaps something like

    Nicks = db [
        jacob jake
        william bill
        robert bob
        ]
    Nicks:william Bill

## Indexing

### Inner Goals

Prolog clause indexing is an optimization to avoid executing clauses that we know will fail.  Most Prolog implementations only index static terms in a clause’s head.  Of course, goals in a clause body can also fail.  It would be neat if body goals could propagate information to the index to make it more efficient.  For example

    foo(A) :- A = hi.

should be indexed exactly like

    foo(hi).

A comment by Bart Demoen on the email thread "SWI-Prolog version 7 proposed changes" says that this behavior for unification goals was standard practice 30 years ago in BIM-Prolog and Aquarius Prolog.

I want the idea to extend further than simple unification goals.  For exmaple, imagine that `new_foo(Foo)` unifies Foo with a foo/3 compound term.  Then

    stuff(Foo) :-
        new_foo(Foo).

should index the exact same as

    stuff(foo(A,B,C)) :-
        Foo = foo(A,B,C),
        new_foo(Foo).

This is really just an implementation detail and doesn't impact how the language itself works.  I'm not sure we want a separate mechanism for predicates to specify how they are indexed.  Rather, we should just infer that indexing based on existing definitions.


## Questions

It should be possible to store databases inside facts in another database.  How does that look/work?

How is comparison defined on database values?

Does GC need to work any differently with database values compared to other values?  I suspect not, but make sure to think through the full GC story.  I anticipate that databases will eventually be used to store short term, transitory data as well as long term data like code.
