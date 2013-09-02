# Random, Unorganized Thoughts

Positional parameter order doesn’t matter if types are unambiguous.  For example, `substring “foo” 1` and `substring 1 “foo”` give identical results.  This use case doesn’t seem fundamental.  One should be able to implement it in terms of macros, type annotations, reflection and run-time “predicate missing” errors.

Currying for arbitrary positional or named parameters.  For example, `substring 1` produces a functions which drops the first character of a string; `substring “foo”` produces a function which gives substrings of “foo”. The SRFI specifying 'cut' suggests another useful way to describe partial function application: (cut substring <> "foo")

String type is called “text” so that it’s shorter

Programs are compiled into statically linked binaries

structs are allowed to reuse accessor names used by other structs. type inference should discern which of the accessor functions is needed for any given invocation.

Built in support for laziness and futures. These are very hard to add to a language without compiler support. Using a lazy or future value should not require a force function.  Creating them may require special syntax but using them must be identical to using other variables.

Support both pre- and post-unification hooks.  Post-unification hooks are nearly identical to attributed variables in Prolog.  They allow unification to happen and then seek additional goals.  There should also be a way to seek additional goals immediately before attempting unification.  In both cases, variable bindings made in these goals are undone on backtracking.  Many use cases for pre-unification hooks can be emulated with post-unification hooks and a compound term wrapper.  Unfortunately, this is nearly the same as requiring a forcing function on futures and lazy values, which is ugly.  More importantly, a forcing function requires infectious changes to consumers when a library decide to lazify one of its return values.  A consumer should never have to change its code based on changes a library makes to internal implementation details.  Make sure that lazy goals (invoked only when needed) and parallel futures (work starts in parallel; blocks until value ready) can be implemented in terms of this underlying, post-unification hook mechanism.

Pre-unification hooks should only be run if we’re about to unify that specific variable, not a parent term.  For example if X has a pre-unify hook, it should not run during: foo(X) = bar(test).  That’s because unification fails on the compound term’s name before ever trying X=test.

Offer generic collection literals (probably with [] syntax) and let the compiler choose which collection data structure to use based on how the collection itself is used in the program. Developers could choose a specific implementation if they needed to. For example, a collection that's only iterated left to right might be implemented as a linked list. A collection that's only tested for membership could be implemented as a set. A small collection that's treated as a map could be an association list, whereas a large one could be a hash map. The compiler should be free to change implementations at runtime as conditions change. It could also make those decisions based on profile data. The main point is that a developer shouldn't have to think about a bunch of data structure implementation tradeoffs or guess how they'll affect performance.

A Prolog like language should be able to reorder goals inside a clause based on a goal's probability of failure and its likely execution cost.  For ideas on implementing this, see Efficient Reordering of Prolog Programs by Gooley and Wah, 1988.

Allow developers to supply multiple implementations of a single function/procedure and have the compiler choose among them based on inferred/measured performance characteristics. For example, a sort function might have implementations for insertion sort, bubble sort, quick sort and merge sort. For very small lists, the compiler might choose to use bubble sort. For a large list, it might choose merge sort. For code that only uses the first few elements of the sorted list, it might choose a lazy merge sort. Perhaps developers could annotate their implementations with Big-O notation on computation and memory to help the compiler make an initial selection before any other data is available.

No null value. See http://qconlondon.com/london-2009/presentation/Null+References:+The+Billion+Dollar+Mistake

Consider using a language tool chain like LLVM or PyPy which can do JIT. PyPy handles garbage collection too. JIT is pretty much essential these days for a new language to compete with the big boys.

A language like Prolog which defines relations between variables. However those relations should all be lazy like CLP(FD) or coroutines. This allows greater code reuse (arbitrary modes permitted, constraint reordering). It also gives the compiler greater flexibility to rearrange clauses for performance gains.

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

Prolog clause indexing is an optimization to avoid executing clauses that we know will fail.  Most Prolog implementations only index static terms in a clause’s head.  Of course, goals in a clause body can also fail.  It would be neat if body goals could propagate information to the index to make it more efficient.  For example

    foo(A) :- A = hi.
  
should be indexed exactly like

    foo(hi).


I've implied elsewhere that Amalog allows users to define operators.  That feature and how it works should be an explicit part of the spec.  When reading an Amalog file as data, one should be able to specify which operators apply.  That way, one can specify operators for a config file syntax before loading the config file.  This gives sugary pleasantness and lets developers reues Amalog's parser, file loading and macro facility.
