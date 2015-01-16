# Variables

Most programming languages take the same approach to variables.  Prolog at least experiments with something different.  It seems like there's a more general approach to variable which is simple and encapsulates all (or most) existing approaches to variables.

## Use cases

Here are some thing I'd like to be able to do with variables in Amalog.

### Logic Variables

Most of the time I want variables that behave exactly like Prolog's logic variables.  They start unbound.  While unbound, they can be entangled with other variables (eg `X = Y, Y = 2, X == 2`).  They can be assigned a nonvar value only once.

### Implicit Type Conversions

Lua and Perl both do implicit type conversions between text and numbers.  So `7 + "2"` gives `9`.  JavaScript does something similar but gives preference to strings so you get `"72"` instead.

Implicit conversion can be confusing and hide real errors so it shouldn't be the default.  However, I'd love to opt-in sometimes.  It gets tiresome calling `number_atom/2` and `number_codes/2` everywhere.  It'd be cool to declare a variable as a "forgiving" integer.  Assigning `"123"` to it automatically converts to `123`.  It'd be helpful for converting from strings to atoms too.

Perhaps a forgiving variable calls a `term_string/2` predicate if someone tries to unify it with a string.

### Lazy Variables

Lazy variables are a great convenience and optimization in certain circumastances.  Lazy-by-default is a bit much for my taste.  For example, I'd like `lazy(atom_codes(A,C))` to delay the calculation until either `A` or `C` is needed.  The variables `A` and `C` are both lazy.  The behavior is associated with the variable not `lazy/1` or `atom_codes/2`.

### Futures

Futures (like Alice ML) are a great way to abstract away parallel computations.  I'd like `spawn(expensive(A,B))` to spark a parallel computation for `expensive/2` and block if `A` or `B` is used before the computation has finished.  The variables `A` and `B` are both "futuristic" (or some such).  The behavior is associated with the variable, not the predicate.

### Attributed Variables

Prolog has shown the power of attributed variables.  library(clpfd) and library(when) and `freeze/2` are all great examples of their power and productivity.

### LVars

I really like the inherent power of [LVars](composition.al/blog/categories/lvars/).  It feels like a generalization of Prolog logic variables with a programmable definition of progress.  Counters and sets and other CRDTs are other applications.  We might consider a variable containing probability values.  Storing a new value multiplies with the existing value (the probability that both events happen).  There are many others.

All variables (in all languages) have an implicit progress function attached to their variables.  It must be true before the new value can be stored in the variable.  Mutable, imperative languages use the trivial progress function (always true).  Logic languages consider three states: unbound, entangled, bound returning false in some combinations.  LVars consider progress based on join semantics and sometimes throw exceptions on read.

I'd like to be able to create a variable with custom progress semantics.  It's not related to the type of data stored in the variable.  In some a variable containing a set is making progress if the set gets larger; othertimes when it gets smaller.

Make sure that all the above use cases can be implemented using Amalog's variables.

## Void

Prolog has the notion of anonymous variables (`_`).  Sometimes they're called "void".  They're just like normal variables but the developer doesn't have to think of a name.  Because they have no name, it's impossible to refer to them elsewhere in the code.  As far as the data flow is concerned, an anonymous variable is a dead end.  Any computations that lead solely to that value could be discarded by an optimizer.

Of course, sometimes an anonymous variable is used to say, "There's a solution but I don't care what it is".  We still have to perform the search to verify that a solution exists.  In that case, backtracking over subsequent solutions is pointless.  I believe that Mercury trims choicepoints in this context.

Having said all that, this is probably an area for optimizing compilers to worry about.  I don't see any reason why these optimizations should be part of the language itself.

## Scratch

Built in support for laziness and futures. These are very hard to add to a language without compiler support. Using a lazy or future value should not require a force function.  Creating them may require special syntax but using them must be identical to using other variables.  These behaviors seem closely tied to the variable that contains them.

A language like Prolog which defines relations between variables. However those relations should all be lazy like CLP(FD) or coroutines. This allows greater code reuse (arbitrary modes permitted, constraint reordering). It also gives the compiler greater flexibility to rearrange clauses for performance gains.  Mercury shows how much performance you can get by reordering clauses.
