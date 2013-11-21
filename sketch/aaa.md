# Random, Unorganized Thoughts

Positional parameter order doesn’t matter if types are unambiguous.  For example, `substring “foo” 1` and `substring 1 “foo”` give identical results.  This use case doesn’t seem fundamental.  One should be able to implement it in terms of macros, type annotations, reflection and run-time “predicate missing” errors.

Currying for arbitrary positional or named parameters.  For example, `substring 1` produces a functions which drops the first character of a string; `substring “foo”` produces a function which gives substrings of “foo”. The SRFI specifying 'cut' suggests another useful way to describe partial function application: (cut substring <> "foo")

String type is called “text” so that it’s shorter

Programs are compiled into statically linked binaries

structs are allowed to reuse accessor names used by other structs. type inference should discern which of the accessor functions is needed for any given invocation.

Offer generic collection literals (probably with [] syntax) and let the compiler choose which collection data structure to use based on how the collection itself is used in the program. Developers could choose a specific implementation if they needed to. For example, a collection that's only iterated left to right might be implemented as a linked list. A collection that's only tested for membership could be implemented as a set. A small collection that's treated as a map could be an association list, whereas a large one could be a hash map. The compiler should be free to change implementations at runtime as conditions change. It could also make those decisions based on profile data. The main point is that a developer shouldn't have to think about a bunch of data structure implementation tradeoffs or guess how they'll affect performance.

A Prolog like language should be able to reorder goals inside a clause based on a goal's probability of failure and its likely execution cost.  For ideas on implementing this, see Efficient Reordering of Prolog Programs by Gooley and Wah, 1988.

Allow developers to supply multiple implementations of a single function/procedure and have the compiler choose among them based on inferred/measured performance characteristics. For example, a sort function might have implementations for insertion sort, bubble sort, quick sort and merge sort. For very small lists, the compiler might choose to use bubble sort. For a large list, it might choose merge sort. For code that only uses the first few elements of the sorted list, it might choose a lazy merge sort. Perhaps developers could annotate their implementations with Big-O notation on computation and memory to help the compiler make an initial selection before any other data is available.

No null value. See http://qconlondon.com/london-2009/presentation/Null+References:+The+Billion+Dollar+Mistake

Consider using a language tool chain like LLVM or PyPy which can do JIT. PyPy handles garbage collection too. JIT is pretty much essential these days for a new language to compete with the big boys.

My ideal language is a constraint logic language because functional programming is a subset thereof.

merd uses WYSIHIIP to let whitespace dictate parenthesis. An interesting idea. I'd have to play with it for a while to see how it works in practice. This approach might allow one to eliminate all operator precedence levels.

Operator precedence numbers are obnoxious. It'd be nice to use the Cecil way: define a partial-order relation on operators.

Postfix operators are convenient for syntactic sugar.  For example, a date library which defines days, weeks, hours, etc. as postfix operators allows: add(Date0, 3 days, Date).

Efficient data structures typically have a larger impact on runtime performance than efficient programming languages.  That suggests that a language should focus on being able to easily reuse libraries that implement efficient data structures.

To facilitate tooling, one should be able to easily tokenize the language without having to parse it.  For syntax highlighting, rudimentary syntax checking, style checking, pretty printing, etc., a quick tokenization phase is enough.  It should be easy to do.

Hooks should be available for when a lexical scope is exited.  Perl’s reference counting garbage collector accidentally allows this feature and it’s used so heavily that it’s bundled in the Scope::Guard module.  Go acknowledges this with its defer facility.  It’s very useful for automatically releasing resources when finished.  In a Prolog-like language, it might be used for creating lexically scoped flags (by wrapping current_prolog_flag/2 and set_prolog_flag/2).

A programming language should define a small set of orthogonal constructs.  It’s OK if they’re unpleasant to work with directly.  Powerful macro facilities translate sugary goodness into these low level constructs.  That keeps the core language small while allowing people to experiment with syntax and control structures.  The market can easily switch between the sugar that works best.

Language releases should break backwards compatibility regularly and without hesitation.  One of the most destructive forces in programming language development is stagnation induced by a constant pressure to support mistakes of the past.  By breaking backwards compatibility on a regular basis (once a year?), the community grows accustomed to it and builds tools to work through the pain.  For example, during early development of Go and Dart, the languages were changing rapidly.  They each developed tools to automatically migrate from old code to new code.  Upgrading to a new release effectively became: download release, go fix, go test, done.  If a language is isomorphic, breaking syntax changes can be supported by reading the old format and writing the new format.  We only commit to writing and running the newest language, but retain code reading ability for a release or two.  Using semantic version numbers for the language would give us a predictable way to describe when backward compatibility has broken.

Shebang syntax (#! as first two characters) should be supported so that one can write Unix scripts in the language.

After an optional shebang line, the first content of the file should be a version indicator.  Running code for a version later than the current interpreter causes a compile time error.  Having the version right up front lets us make dramatic changes to the language .  It also allows tools to know which version this code was written for.

There should be one set of comparison operators that works across values, regardless of their type.  For example, Prolog has < and @<. The latter is necessary because the former confounds arithmetic evaluation and value comparison.  The latter does straight value comparison.  Orthogonal concepts should almost never be combined, because the can’t be separated afterwards.

Haskell’s comparison operators are great because one can overload them to behave correctly for one’s domain.  Prolog’s @< operator is great because it allows one to compare all possible data values.  This saves developers from exponential comparison explosion (one library defining how its values compare to all other library’s values).

It might be cool if all comparisons were just sugar for a deterministic call to predicate `compare/3`.  For example, `A<B` is desugared to `once(compare(<,A,B))`.  Then libraries can add clauses for compare/3 to support comparisons between their own values.  All other values retain standard value comparison.

I've implied elsewhere that Amalog allows users to define operators.  That feature and how it works should be an explicit part of the spec.  When reading an Amalog file as data, one should be able to specify which operators apply.  That way, one can specify operators for a config file syntax before loading the config file.  This gives sugary pleasantness and lets developers reues Amalog's parser, file loading and macro facility.


# Bayesian Programming

Logic programming is just a database of relations plus a search algorithm.  Could there be Bayesian programming?  The database is probabilistic relations and the search algorithm is Bayesian search.  We calculate the probability of a solution (S) based on the probability of a term (T) using Bayes formula

    P(S|T) = P(T|S) * P(S) / P(T)

As with Prolog, computation starts with an initial goal term T.  The developer defines the probability of each term (giving us `P(S)` and `P(T)`).  He also defines the probablity of each relation (gives us `P(T|S)`).  The top level calculates all solutions `S` and iterates them in order of increasing probability.  One might constrain solutions to only those exceeding a certain probability threshold.

It seems like logic programming is a subset of Bayesian programming in which all probabilities are 1 (success) or 0 (fail).  See [probabilistic logic](https://en.wikipedia.org/wiki/Probabilistic_logic) for work in this area.

[ProbLog](http://dtai.cs.kuleuven.be/problog/) seems to be the most fully developed tool in this space.  It has a [tutorial](http://dtai.cs.kuleuven.be/problog/tutorial.html) and plenty of academic papers on the subject.


# Homoiconic

It seems that many of Prolog's powerful features derive from its homoiconicity.  Constructing macros, transforming programs, creating dynamic predicates, etc. all benefits from homoiconicity.  At heart, a language is homoiconic if its programs are represented as a primitive data type in the langugae.  That's a little vague because a Python program could parse into an AST built out of dictionaries.  However the native representation of those dictionaries is different than the source code.

I want an objective rule to make sure that Amalog is homoiconic.  Perhaps isomorphism already gives me that.  I should be able to read a program into a data structure and then write that data structure in its native form to get the exact same program I started with.  I can build up a data structure and write it out to get a program which, when parsed produces the same data structure.

# Quantum Mechanics

Quantum mechanics offers some interesting parallels to logic programming.  Unifying two unbound logic variables [entangles](http://en.wikipedia.org/wiki/Quantum_entanglement) them so a change to one is immediately reflected in the other.  Constraint logic programming (like library(clpfd)) creates [variable superposition](http://en.wikipedia.org/wiki/Quantum_superposition) with multiple values seemingly stored in a single variable.  Mercury (and Haskell's) type inference for type classes reminds me a lot of the [quantum eraser](http://en.wikipedia.org/wiki/Quantum_eraser_experiment) (want a particle, get a particle; want a wave, get a wave).

What other quantum phenomenon could be implemented as features of a programming language?  How would they be useful?

# Lists as Interface

Richard A. O'Keefe, in a discussion about strings vs code lists says:

> In the same way, in the NU Prolog approach, a byte-per-element string
> *IS* a code list, just stored differently.

This is a vital point.  A list is really just an interface to some data.  Namely the interface that lets you conveniently access the first element and the rest of the elements.  [Clojure sequences](http://clojure.org/sequences) make the exact same realization.  Anything that provides the `[H|T]` interface (in Prolog syntax) can be treated as a list.  Strings can implement it (giving character codes), databases can implement it (giving clauses), streams can implement it (giving bytes), trees can implement it (giving in-order traversal), maps can implement it (giving pairs), etc.

Prolog works great on lists.  One does a great harm when "list" is forced to mean only a "cons-cell linked list."

We might imagine a predicate `sequence(Head, Tail, Whole)` where

    sequence(-Head, -Tail, +Whole) % take apart a sequence
    sequence(+Head, +Tail, -Whole) % assemble a sequence from parts

Any data structure could implement clauses for this predicate to act like a list.  `[H|T]` is just syntactic sugar for `sequence/3` like this:

    foo([H|T]).
    % -- desugars to -->
    sequence(H, T, Whole),  % delays until a valid mode is found
    foo(Whole).
