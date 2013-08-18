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
    Nicks0 = {}     // sugar for: new_db Nicks0
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
