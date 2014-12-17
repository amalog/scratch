# Random, Unorganized Thoughts

Positional parameter order doesn’t matter if types are unambiguous.  For example, `substring “foo” 1` and `substring 1 “foo”` give identical results.  This use case doesn’t seem fundamental.  One should be able to implement it in terms of macros, type annotations, reflection and run-time “predicate missing” errors.

Currying for arbitrary positional or named parameters.  For example, `substring 1` produces a functions which drops the first character of a string; `substring “foo”` produces a function which gives substrings of “foo”. The SRFI specifying 'cut' suggests another useful way to describe partial function application: (cut substring <> "foo")

String type is called “text” so that it’s shorter

Programs are compiled into statically linked binaries

structs are allowed to reuse accessor names used by other structs. type inference should discern which of the accessor functions is needed for any given invocation.

Offer generic collection literals (probably with [] syntax) and let the compiler choose which collection data structure to use based on how the collection itself is used in the program. Developers could choose a specific implementation if they needed to. For example, a collection that's only iterated left to right might be implemented as a linked list. A collection that's only tested for membership could be implemented as a set. A small collection that's treated as a map could be an association list, whereas a large one could be a hash map. The compiler should be free to change implementations at runtime as conditions change. It could also make those decisions based on profile data. The main point is that a developer shouldn't have to think about a bunch of data structure implementation tradeoffs or guess how they'll affect performance (unless they want to).

If this "pretend there's only one collection data type" idea sticks, maybe allow any of `[]`, `{}` or `()` to indicate a collection.  Developers may settle on a convention by assigning a particular punctuation to a particular data structure even though the compiler makes the final choice based on usage and available libraries.

Another approach to collections is to support lists (probably `[]` syntax), sets (probably `{}` syntax) and maps (maybe `()` with `:` syntax).  Expand that syntactic sugar into a series of predicate goals.  Those goals define an interface for each data structure.  Along the lines of [Breaking the Complexity Barrier of Pure Functional Programs ...](https://lirias.kuleuven.be/bitstream/123456789/201251/1/preliminary.pdf), the compiler chooses an implementation that works well (perhaps persistent, perhaps mutable, etc).  By programming to an interface, the compiler may be able to choose a really fast implementation.  It also allows new implementations to come along later and old code gets the benefits.  Rudimentary compilers could provide only a single implementation (based on an internal map data structure) as an easy way to bootstrap an Amalog implementation.

Strings should operate in the same way as collection data structures.  Strings and operations against them are sugar against an interface.  We can change the underlying implementation of strings based on how the developer interacts with those strings.  This lets libraries supply better string implementations (ala Haskell's `Data.Text` package), if that becomes useful.

A Prolog like language should be able to reorder goals inside a clause based on a goal's probability of failure and its likely execution cost.  For ideas on implementing this, see Efficient Reordering of Prolog Programs by Gooley and Wah, 1988.

Allow developers to supply multiple implementations of a single function/procedure and have the compiler choose among them based on inferred/measured performance characteristics. For example, a sort function might have implementations for insertion sort, bubble sort, quick sort and merge sort. For very small lists, the compiler might choose to use bubble sort. For a large list, it might choose merge sort. For code that only uses the first few elements of the sorted list, it might choose a lazy merge sort. Perhaps developers could annotate their implementations with Big-O notation on computation and memory to help the compiler make an initial selection before any other data is available.

No null value. See http://qconlondon.com/london-2009/presentation/Null+References:+The+Billion+Dollar+Mistake

Consider using a language tool chain like LLVM or PyPy which can do JIT. PyPy handles garbage collection too. JIT is pretty much essential these days for a new language to compete with the big boys.

My ideal language is a constraint logic language because functional programming is a subset thereof.

Efficient data structures typically have a larger impact on runtime performance than efficient programming languages.  That suggests that a language should focus on being able to easily reuse libraries that implement efficient data structures.

To facilitate tooling, one should be able to easily tokenize the language without having to parse it.  For syntax highlighting, rudimentary syntax checking, style checking, pretty printing, etc., a quick tokenization phase is enough.  It should be easy to do.

Hooks should be available for when a lexical scope is exited.  Perl’s reference counting garbage collector accidentally allows this feature and it’s used so heavily that it’s bundled in the Scope::Guard module.  Go acknowledges this with its defer facility.  It’s very useful for automatically releasing resources when finished.  In a Prolog-like language, it might be used for creating lexically scoped flags (by wrapping current_prolog_flag/2 and set_prolog_flag/2).

A programming language should define a small set of orthogonal constructs.  It’s OK if they’re unpleasant to work with directly.  Powerful macro facilities translate sugary goodness into these low level constructs.  That keeps the core language small while allowing people to experiment with syntax and control structures.  The market can easily switch between the sugar that works best.

Language releases should break backwards compatibility regularly and without hesitation.  One of the most destructive forces in programming language development is stagnation induced by a constant pressure to support mistakes of the past.  By breaking backwards compatibility on a regular basis (once a year?), the community grows accustomed to it and builds tools to work through the pain.  For example, during early development of Go and Dart, the languages were changing rapidly.  They each developed tools to automatically migrate from old code to new code.  Upgrading to a new release effectively became: download release, go fix, go test, done.  If a language is isomorphic, breaking syntax changes can be supported by reading the old format and writing the new format.  We only commit to writing and running the newest language, but retain code reading ability for a release or two.  Using semantic version numbers for the language would give us a predictable way to describe when backward compatibility has broken.

Shebang syntax (#! as first two characters) should be supported so that one can write Unix scripts in the language.

After an optional shebang line, the first content of the file should be a version indicator.  Running code for a version later than the current interpreter causes a compile time error.  Having the version right up front lets us make dramatic changes to the language .  It also allows tools to know which version this code was written for.

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

# Large Number Arithmetic

Paul Tarau has [done](http://logic.cse.unt.edu/tarau/research/2013/hbn.pdf) [some](http://logic.cse.unt.edu/tarau/research/2013/slides_ciclops13.pdf) [work](http://logic.cse.unt.edu/tarau/research/2013/rrl.pdf) on representing large numbers as Prolog terms.  One can perform computation on these large numbers very efficiently and they occupy very little memory.

It could be cool to have an implementation of Amalog numbers which works this way internally.  When the system encounters numbers larger than the native word size, upgrade to this representation internally.

It might also work better as a basis for clpfd because the math operations are mostly reversible.

Incidentally, using this implementation for numbers would eliminate numbers as a fundamental type in Amalog.  I don't know that that's a primary goal, but it's something worth thinking about.  All arithmetic operations would then be defined in terms of Amalog code so it'd be identical across platforms, regardless of their number implementation (think JavaScript).  I'm just guessing that there are substantial performance implications on typical code.  If this is the interface for numbers, an Amalog implementation can always choose to implement them more efficiently in specific cases.

# Backtracking Hooks

[SICStus undo/1](http://sicstus.sics.se/sicstus/docs/3.12.8/html/sicstus/Misc-Pred.html) predicate schedules a goal to be called on backtracking.  It requires system support to make it immune to cuts.  [Mercury trailing](http://www.mercurylang.org/information/doc-latest/mercury_ref/Trailing.html) offers a similar feature (only for C code for now).  Jekejeke Prolog [supports sys_unbind/1](https://plus.google.com/+JekejekeCh/posts/R3abr1AMDkp) which does something very similar.

I've wanted programmable backtracking on several occasions.  It would be nice to have it in Amalog.  The first time I ever thought about this was when writing `gitc` for Grant Street Group.  We perform a bunch of Git commands on a repository.  If everything succeeds, the `gitc` finishes and none of the side effects are undone.  However, if something goes wrong we backtrack, undoing side effects along the way, and try again.  This can't be done with call_cleanup/2 because that cleanup code is called on success and failure.

A weak form of this predicate could be implemented as:

    undo _
    undo Goal
        Goal
        !
        fail

but another goal can cut away undo's choicepoint preventing it from being executed on backtracking.  I don't think undo/1 be implemented in terms of call_cleanup/2 or `setup_call_catcher_cleanup/4` because we still need a way to schedule code on backtracking, even if we can preserve state across backtracking and cut.

# Code Studies

Programming language design is far too subjective.  I'd love to perform large scale studies on existing Prolog code to see how real world programmers behave.  What are the most popular goals?  What are the most popular variable names? How complex is a typical clause?  How many clauses does a typical predicate have? Are there popular goals which are always called in the same pattern? For example, `member/2` called with a variable first argument and a static list as the second argument.

With data like this, one should be able to discern patterns that should be factored out to libraries or language constructs.

# fail

Prolog uses "fail" to mean "I was unable to prove your goal".  That word has a perfect alignment with English usage ("fail - be unsuccessful in achieving one's goal").  Unfortunately, the word "fail" has a connotation that something went wrong or something unexpected happened.  In most cases, Prolog failure is more like `return false` in other languages.  Consider how "fail" is handled by `-> ;` or `partition/4`.  SWI-Prolog's even displays "false" when it can't prove a top level goal.

I'd like to reserve "fail" for signaling error conditions.  Or maybe "err" could suffice (used in similar contexts by Go and Perl 6).

Perhaps `no` is a better term to indicate that there is no proof of one's goal.  It has a clear opposite (`yes`).  This also leaves `true` and `false` free for use as boolean values; distinct from proof success-failure values.

# Universality and Expressiveness of fold

The paper of this same names suggests a mechanized way to transform recursively defined functions (or predicates) into equivalents defined with foldr or foldl.   Once defined with fold, these predicates can be subjected to fusion and other transformations valuable to a partial evaluator.

Amalog's macro mechanism should be able to describe the transformation from recursion into fold (transformation across clauses of a predicate).

One idea to consider is using [linear logic programming](www.infoq.com/presentations/linear-logic-programming) as a language for describing macros.  Imagine a predicate definition described in terms of "resources".  Linear logic rules consume those resources and produce new ones.  When applying rules reaches a fixed point, transform the remaining resources back into a predicate definition.

Users probably don't write their macros directly in a linear logic language.  They typically write something that's closer to `term_expansion/2` but we expand that into the lower-level linear logic formalism for implementation.  Users could write the low-level code, if they really wanted/needed to.

# Interclausal Logic Variables

The [paper by this name](http://arxiv.org/pdf/1406.1393v1.pdf) suggests a simple semantics and implementation for global logic variables in a Prolog.  This idiea fits very well with some of my thoughts about referencing third party libraries with a variable name.  The paper also shows some interest problems that can be solved readily with this idea.

It seems like a powerful primitive to add to Amalog.  Unlike many features, it seems fairly fundamental.  However, the paper suggests one implementation in terms of a source transformation.  So maybe this can/should be implemented as a library.

# Universal Function Call Syntax

The D language has [universal function call syntax](http://ddili.org/ders/d.en/ufcs.html) which converts `foo.bar` into `bar(foo)`.  It's pure syntactic sugar but seems pretty helpful in certain circumstances.  For example,

    writeln(evens(divide(multiply(values, 10), 3)))

can be rewritten as

    values.multiply(10).divide(3).evens.writeln

That keeps functions and their arguments nearby (ie `divide(10)` instead of `divide(..., 10)`).  It also makes the computation read left to right in the same order in which evaluation occurs. The latter is sort of like inline DCG syntax since it operates on an implicit state.

# One predicate per file

## Conceptual background

A clause is the smallest unit of code reuse in a logic programming language.  The smallest unit of API is the predicate.  A developer crafts a new predicate by describing the relationship between his predicate and these other predicates.

Ideally, he'd have a window showing the source code of his predicate.  He'd also have windows showing the code/documentation for the other predicates in the relation.

Unfortunately, tradition stores many predicates in a single file.  A developer must therefore open multiple views on that file, scrolling to show just the piece he cares about.  Auxiliary predicates, defined in the same file, muddle the situation further.  Are these predicates intended for public consumption?  Or are they just "lemmas" upon which the public predicate is being built.

Haskell tries to address the lemma situation by allowing the developer to declare local functions via `where` syntax.  That makes it clear which functions are lemmas and which are "theorems", so to speak.

## Version control background

Storing multiple predicates in a single file also brings version control headaches.  Version control works with files.  When multiple changes happen to a file, tools must perform a merge operation.  Merge operations have a non-trivial probability of failure.  Moving code from one file to another file often requires merge operations on multiple files which increases the probability of something going wrong.

On projects like the Linux kernel or Bitcoin Core, splitting a single massive file into smaller, more manageable, cleaner pieces becomes [socially contentious](http://sourceforge.net/p/bitcoin/mailman/message/33156121/).  That account describes how it even discourages contributors from working on the code.

Had these projects started with cleanly factored code bases, much of the social cost of version control would dissipate.

## Proposal

In Amalog, each file describes a single predicate that's intended for use outside that file.  A file may contain other predicates, but they must be named with a trailing underscore to indicate that they are lemmas intended only for consumption within the file.

If Amalog ends up using universally unique identifiers for predicates, the public predicate is placed under the public namespace.  The lemmas are placed in a random, per-file namespace.  Of course, these visibility constraints are only convention.  If someone knows the full identifier for a lemma, he can call it.  By convention, however, the lemma may change behavior or name.

Attempting to define two public predicates in a single file is a syntax error.  If two predicates want to share a lemma, that lemma must be placed in its own file.  It doesn't have to be announced for public consumption but it can no longer live in the original file as a lemma.

Most text editors have excellent support for rapidly locating and switching between files.  This support is typically better than is support for locating and switching between positions in a single file.  This should make it easier to quickly navigate to a predicate definition without secondary tools (like ctags, etc).
