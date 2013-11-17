# Variables

Most programming languages take the same approach to variables.  Prolog at least experiments with something different.  It seems like there's a more general approach to variable which is simple and encapsulates all (or most) existing approaches to variables.


## Scratch

Built in support for laziness and futures. These are very hard to add to a language without compiler support. Using a lazy or future value should not require a force function.  Creating them may require special syntax but using them must be identical to using other variables.  These behaviors seem closely tied to the variable that contains them.

A language like Prolog which defines relations between variables. However those relations should all be lazy like CLP(FD) or coroutines. This allows greater code reuse (arbitrary modes permitted, constraint reordering). It also gives the compiler greater flexibility to rearrange clauses for performance gains.  Mercury shows how much performance you can get by reordering clauses.
