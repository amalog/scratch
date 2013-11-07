# Scratch

## Numbers and Databases

I want Amalog to have very few types.  I originally planned for two: numbers and nodes.  A node generalizes Prolog compound terms and Prolog atoms. However I also want first class databases and first class maps.

Taking the list of types from a [typical modern language](http://www.lua.org/pil/2.html), adding those needed by a logic languge (`atom` and `compound term`) and removing those not needed by a logic language (`nil`, `boolean`, `function`) we end up with the following types:

  * number
  * atom
  * string
  * compound term
  * array
  * map
  * thread

Lua has had great success replacing `array` with a `map` ("table") whose keys are all integers, `N > 0`.  What if we follow the same exercise and consolidate nearly everything into a database.

A database is a name and list of clauses.  An advanced implementation will have many specialized implementations, but using Go-like notation we can start with:

    type Database struct {
        Name    string
        Clauses []Database
    }

I'll use Prolog module notation to show how each type can be represented as a database.  `number` is fundamental (arbitrary precision rationals).

### Atom

The atom `foo` is represented as an empty database with just a name:

    Database{
        Name = "foo"
        Clauses = []
    }

### String

Use atoms to represent strings.  Most Prolog implementations separate them, but they're semantically close enough that I think they should be merged.  The string `"foo"` is an empty database with a name.

    Database{
        Name = "foo"
        Clauses = []
    }

Of course an optimized implementation would represent common strings/atoms as an integer and perform comparisons and unifications against the number rather than the entire content.

### Compound Term

A compound term has a name and several subterms in a specific order.  `foo(a,b,c)` is:

    Database{
        Name = "foo"
        Clauses = [
            Database{Name="0", Clauses=[Database{Name="a"}]}
            Database{Name="1", Clauses=[Database{Name="b"}]}
            Database{Name="2", Clauses=[Database{Name="c"}]}
        ]
    }

### Array

An array or list is nearly identical to a compound term but has a conventional, internal-looking name.  `[a,b,c]` is:

    Database{
        Name = "__array"
        Clauses = [
            Database{Name="0", Clauses=[Database{Name="a"}]}
            Database{Name="1", Clauses=[Database{Name="b"}]}
            Database{Name="2", Clauses=[Database{Name="c"}]}
        ]
    }

To access the elements of an array, one calls a predicate, just like for other keys.

    ?- Db:1(X).
    X = b.
    ?- N=1, Db:N(X).
    X = b.

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

    ?- Db:b(X).
    X = 2.
    ?- Key=b, Db:Key(X).
    X = 2.

### Thread

This is probably a primitive type.  It doesn't have a natural mapping to databases.
