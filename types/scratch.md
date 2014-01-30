# Scratch

## Numbers and Databases and Variables

I want Amalog to have very few types.  I originally planned for two: numbers and nodes.  A node generalizes Prolog compound terms and Prolog atoms. However I also want first class databases and first class maps.

Taking the list of types from a [typical modern language](http://www.lua.org/pil/2.html), adding those needed by a logic languge (`atom` and `compound term`) and removing those not needed by a logic language (`nil`, `boolean`, `function`) we end up with the following types:

  * number
  * atom
  * string
  * compound term
  * array
  * map
  * thread

Lua has had great success replacing `array` with a `map` ("table") whose keys are all integers, `N > 0`.  What if we follow the same exercise and consolidate nearly everything into a database type.

A database is a name and list of clauses.  An advanced implementation will have many specialized implementations, but using Go-like notation we can start with:

    type Term = Number | Database
    type NameId int64
    type Database struct {
        Name    NameId
        Clauses []Term
    }

`NameId` is just an integer which looks up a human readable name from a global table.  Small names can be treated as base-32 integers so the lookup table isn't needed.  For large names, the ID might be a hash of its contents.

I'll use Prolog module notation to show how each desired type can be represented as a database.  `number` is fundamental (arbitrary precision rationals).

In these examples, I write `Name` as if it were string.  That's shorthand for the `NameId` mechanism.

### Atom

The atom `foo` is represented as an empty database with just a name:

    Database{
        Name = "foo"
        Clauses = []
    }

Atoms are fancy integers without arithmetic.  They should consume almost no memory and equality comparisons must be very fast. Using a `NameId` for an atom is just right.

### String

The string `"foo"` is represented with one clause per code point.

    Database{
        Name = "__text"
        Clauses = [
            0'f,
            0'o,
            0'o,
        ]
    }

Strings are semantically different from atoms.  With a string, the emphasis is on the content rather than its relation to other strings.

I suppose this means that Amalog indented notation makes `"foo"` syntactic sugar for:

    __text
        0'f
        0'o
        0'o

### Compound Term

A compound term has a name and several subterms in a specific order.  `foo(a,b,c)` is:

    Database{
        Name = "foo"
        Clauses = [
            Database{Name="a"},
            Database{Name="b"},
            Database{Name="c"},
        ]
    }

This arrangement makes arg/3 easy (just array lookup).  It also makes compound terms a natural representation of a multiset of atoms:

    Bag = bag(a,b,c),
    Bag : a.    % true if 'a' is a member of the multiset

This arrangement also makes Amalog indented notation for compound terms quite reasonable.  Each of `a`, `b` and `c` looks just like clauses within the `foo` database, which is exactly what they are.

    foo
        a
        b
        c

### Array

An array or list is nearly identical to a compound term but has a conventional, internal-looking name because the name is irrelevant in this context.  `[a,b,c]` is:

    Database{
        Name = "__list"
        Clauses = [
            Database{Name="a"}
            Database{Name="b"}
            Database{Name="c"}
        ]
    }

To access the elements of an array, one calls a predicate, just like for other keys.

    ?- List : 1(X).
    X = b.
    ?- N=1, List : N(X).
    X = b.

This suggests that `[a,b,c]` is sugar for `__list(a,b,c)`.  So, an array is another natural representation of a multiset.  Although it's less explicit than a `bag` compound term would be.

In indent notation, we have `[a,b,c]` as sugar for

    __list
        a
        b
        c

### Map

A map is like a Prolog database with a predicate for each key.  Like an array, the database name is chosen by convention.  `{a:1, b:2, c:3}` is:

    Database{
        Name = "__map"
        Clauses = [
            Database{Name="a", Clauses=[1]}
            Database{Name="b", Clauses=[2]}
            Database{Name="c", Clauses=[3]}
        ]
    }

Of course, a real implementation would have an index to avoid linear traversal of the map's clauses.

One accesses the elements of a map by using the keys as predicates:

    ?- Map : b(X).
    X = 2.
    ?- Key=b, Map : Key(X).
    X = 2.

In Amalog indent notation `{a:1, b:2, c:3 }` is sugar for

    __map
        a 1
        b 2
        c 3

Depending on the way in which keys and values are added (appended or replaced), a map can be a map or a multimap.  Each value for a key is iterated on backtracking.

### Variables

See [variables document](variables.md) for more thoughts.

A variable is some hooks and a wrapper around a storage location (thread-local or mutex-protected global).  Values are unwound on backtracking.

    type Variable struct {
        Name NameId
        Flavor NameId
        Storage  Ref // thread-local or mutex-protected global
        Hooks Database // goals to call at critical points
    }

By default, a variable's hooks implement logic variable semantics so it behaves exactly like a Prolog logic variable. One can also design and use other variable flavors.  `HookPreLoad` supports Alice ML futures.  `HookPreLoad` and `HookPreStore` support [freeeze-on-read LVars](http://composition.al/blog/categories/lvars/).  `HookPostStore` supports attributed variables.  `HookPreStore` supports variables restricted to a specific type (strings, primes, positive integers, etc).

### Thread

This is probably a primitive type.  It doesn't have a natural mapping to databases.


## psi-terms

The Prolog derivative [LIFE](http://www.din.uem.br/ia/ferramentas/tut_life.gz) is based on psi-terms.  They are an extension of Prolog compound terms where each argument has a name.  See Chapter 3 of the linked document.  It also provides references to other Prolog derivatives based on a similar idea.

LIFE extends a bit too far by supporting inheritance for psi-terms, but I like the basic idea.  It's similar to my goal of consolidating all data types into the database type.  LIFE's implementation of lists, clauses, functions, etc. in terms of psi-terms could be instructive.

Here's Richard A. O'Keefe's summary:

> LIFE uses psi-terms.  A PSI-term is
> - a variable, or
> - a number, or
> - a compound term, which has a function symbol and
> - zero or more arcs labelled with constants leading
>   to other psi-terms
>
> A psi-term whose labels are the integers from 1..N for
>some N is just a Prolog term of arity N.

He also mentions [this LIFE document](http://hassan-ait-kaci.net/pdf/life.pdf).

## Feature Structures

Feature structures are a generalization of first-order terms similar to psi-terms.  See [Unification: A Multidisciplinary Survey](http://www.isi.edu/natural-language/people/unification-knight.pdf) section 7, for details.  However, they don't have a functor and don't do inheritance.  In that sense, they're simpler and very similar to JSON objects.  The impedance match with JSON could be helpful.

Feature structures support both unification and generalization and therefore form a lattice.  Using JSON notation, the unification operator behaves as follows:

```javascript
  {type: "person", name: "john"}
⊔ {type: "person", age: 23 }
⇒ {type:"person", age: 23, name: "john"}
```

As with all unification, it performs a merge that combines information from both terms while discarding none.

So far, I prefer feature structures as Amalog's terms rather than psi-terms or first-order terms.  Unfortunately, feature structures don't seem to allow multiple features with the same name, so we still require a separate term to represent first class databases.  Or perhaps we could extend feature structures to allow multiple values, thereby reducing the number of different types.

Michael Covington has written a [feature structures library](http://www.ai.uga.edu/mc/gulp/) for SWI Prolog.  It supports most of the operations one would want.  It would be good to play with this library to get a feel for how practical they are in the real world.
