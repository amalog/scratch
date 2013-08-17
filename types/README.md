# Spec

There are two fundamental types: node (which includes atoms and compound terms) and number.  Atoms are nodes with arity 0.  Implementations may have dozens of specialized, internal representations for these two types.  In choosing a representation, implementations should prefer accuracy over speed.

More restrictive types are represented as subsets of the values available for those two types.  *By convention*, more restrictive types are declared with `var/2`.  Executing a `var/2` goal constrains the variable to be the intersection of its current type and the new type.

The language distinguishes between production and development modes.  With macros, homoiconicity and development/production modes, users can build nearly all imaginable type systems.


# Examples

Variables are typically used without declaring their type:

    X = foo bar baz
    Y is 2 + 3

Types may be declared if it's desired:

    var X node/2
    var Y num
    X = foo bar baz
    Y is 2 + 3

By exporting clauses for `var/2` or via macros, third party libraries can support additional types or behaviors for type declarations:

    var E expression
    Y is E
    
becomes

    arithmetic_expression_or_die E
    Y is E

An implementation might internally represent `42` as an integer, `43.7` as a rational (437/10) and `log(4327)` as a float.  Notice the use of rationals instead of floats where it’s possible to retain accuracy.  An Amalog implementation must support rationals, but doesn’t have to support integers or floats.  Those are internal implementation details.


# Reasoning

There are millions of application-specific types.  It’s unlikely a language designer can anticipate which types will prove valuable.  It seems similarly arrogant to assume that a language designer can anticipate which type systems will prove valuable or to assume that a single type system should be used in all application domains.

By defining only fundamental types and allowing them to be extended with a Turing complete language, developers can build their own types and type systems.  They can be packaged into libraries and adopted as they prove useful.

An underpowered, static type system does more harm than good.  In statically typed languages, developers spend a great deal of effort creating new types, adding type casts, adding type annotations, etc. to convince a compiler to let them run their program.  Amalog developers can still impose that kind of discipline, if they want, by running strict analysis tools.  Requiring extra work should never be the default.

Numbers could be represented in terms of node values (3 as `succ(succ(succ(zero)))`).  Considering how often numbers are used in computation and how memory intensive their node representation becomes, it seems prudent to have a dedicated number type.

Many complain that JavaScript has only a single numeric type.  In reality, they’re complaining that JavaScript has only floats.  Amalog’s spec sticks with mathematical numbers and allows implementations to represent them in a machine in whichever format it deems most appropriate.  The requirement to focus on accuracy over performance means that one might get slow code by using a different implementation, but he’ll never get wrong code.

There’s no dedicated string type because that type is conceptually just a sequence of numbers.  Most implementations will optimize lists of small numbers into a packed-memory representation identical to strings in other languages.  It's likely that integers created in a character context will use as separate internal representation ("code point", "rune", etc).


# Use Cases

An application may want a text type which never holds empty strings, a character type that only holds 7-bit ASCII characters or a type which only holds prime numbers, etc.

For editors and static analysis tools, `var/2` is just data.  They can offer code completion or type inference or other helpful assistance by analyzing those annotations.

One often wants structural typing rather than nominative typing.  OCaml can define types in terms of  methods and their signatures.  Go interfaces provide something similar, as do Haskell type classes.  Because Amalog types have access to a full Turing-complete language, one can recognize which values comply with a desired structure.

One might define a type in terms of test cases. For example, the type `field Zero One Plus` (representing a mathematical field) could verify that field properties like this are true:

    var X field(Zero One Plus)
        // field properties must hold
        call Plus One Zero One
        call Plus Zero One One
        ...
        
A value claiming to be of `field` type must provide the relevant predicates and those predicates must pass the given test cases.
