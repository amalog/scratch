# Operators

Prefix, infix, circumfix and postfix operators are all convenient to have.  They can make code easier to read, assist with DSLs and avoid [fingernail oatmeal](http://en.wikiquote.org/wiki/Larry_Wall#1994).  However, their traditional implementation requires complex tables of operator precedence.  I've wasted far too much productive time consulting such tables and tweaking the precedence of my operators.

Smalltalk tries to resolve the problem by reducing precedence to only four levels (parens, unary, binary and keyword).  I've seen enough questions online about Smalltalk operator precedence that I'm convinced that even four levels is too many.

What if there were only one level of operator precedence and using multiple, distinct operators (without parens) were a syntax error?  There's no trouble when using the same operator multiple times.  In that case we need associativity not precedence.  Associativity is a simpler property that's independent of the associativity of other operators.

"Any half decent language should only take several pages to implement".  Precedence parsers, although [beautifully clever](http://journal.stuffwithstuff.com/2011/03/19/pratt-parsers-expression-parsing-made-easy/), consume too much of that budget and mostly buy us headaches.

# Will somebody please think of the math!?

Operators and precedence are typically justified as a means for succinctly writing math expressions.  Math is relatively rare in most programs.  There's no need to pollute the entire language for something uncommon that a DSL library can implement so easily:

```
math `X = 27*Y + 3`
```

becomes

```
times 27 Y A
plus A 3 X
```

Using a DSL library for math notation also lets all Amalog implementations to share the same math parser and implementation.

# Examples

Assume reasonable operator definitions below:

  * `hello - world` same as `-(hello world)`
  * `a + b + c` same as `+(a +(b c))`
  * `a + b - c` error "too many distinct operators: please add parentheses"
  * `(a + b) - c` ok
  * `a + (b - c)` ok
  * `7 days` same as `days(7)`

# Scratch

## Punctuation

Punctuation is highly valuable in programming syntax.  It's easy to type, succinct to read visuallly different from surrounding text.  It also provides a recognizable subset of the characters available.

Many languages waste punctuation on rarely used operations like bitwise operators.  In a high level language that rarely twiddles bits, I'd much rather use word operators (xor, and, or, negate) for bitwise operations and reserve punctuation operators (^ & | !) for common operations.

## Natural Programming

Pane, Ratanamahatana, Myers; "Studying the Language and Structure in Non-Programmers’ Solutions to Programming Problems"

In 100% of cases, the not operator has low precedence.  "not a or b" means "not (a or b)".  [Subsequent studies](https://www.cs.cmu.edu/~pane/VL2000.htm), show that "not" has higher precedence than "and" but lower precedence than "or".  The difference across these studies suggests that operator precedence is difficult for non-programmers (to be honest, it's difficult for programmers too).

## Random

merd uses WYSIHIIP to let whitespace dictate parenthesis. An interesting idea. I'd have to play with it for a while to see how it works in practice. This approach might allow one to eliminate all operator precedence levels.

Operator precedence numbers are obnoxious. It'd be nice to use the Cecil way: define a partial-order relation on operators.

Postfix operators are convenient for syntactic sugar.  For example, a date library which defines days, weeks, hours, etc. as postfix operators allows: add(Date0, 3 days, Date).

There should be one set of comparison operators that works across values, regardless of their type.  For example, Prolog has `<` and `@<`. The latter is necessary because the former confounds arithmetic evaluation and value comparison.  The latter does straight value comparison.  Orthogonal concepts should almost never be combined, because they can’t be separated afterwards.

Haskell’s comparison operators are great because one can overload them to behave correctly for one’s domain.  Prolog’s `@<` operator is great because it allows one to compare all possible data values.  This saves developers from exponential comparison explosion (one library defining how its values compare to all other library’s values).

It might be cool if all comparisons were just sugar for a deterministic call to predicate `compare/3`.  For example, `A<B` is desugared to `once(compare(<,A,B))`.  Then libraries can add clauses for `compare/3` to support comparisons between their own values.  All other values retain standard value comparison.

I've implied elsewhere that Amalog allows users to define operators.  That feature and how it works should be an explicit part of the spec.  When reading an Amalog file as data, one should be able to specify which operators apply.  That way, one can specify operators for a config file syntax before loading the config file.  This gives sugary pleasantness and lets developers reuse Amalog's parser, file loading and macro facility.

## Undeclared operators

Declaring operators gives us succinct syntax at the usage location.  It also allows one to use arbitrary characters/atoms as operators (for example, `7 days`).  However, one sometimes prefers a one-off operator.  In this context, the syntactic overhead of a declaration outweighs the benefits gained, so it's not done.  When a one-off operator syntax is available, developers use it frequently.  Obeserve how much Haskell code like this exists:

```
foo = x `bar` y
```

What if one-off operators were preceded by a backslash.  LaTeX uses this syntax to insert symbols, mostly mathematical operators.  We can leverage LaTeX's mapping from symbol names to Unicode for developers who wish to view the Unicode characters rather than the full, canonical backslash syntax.

For example, declaring and using subset with canonical syntax:

```
subset A B Subset
    ...

main
    say A \subset B
```

One might configure his editor to display that as:

```
subset A B Subset
    ...

main
    say A ⊂ B
```

Very few people may configure their editor that way, so that's only minor justification.  The larger justification is a tiny syntax for using any predicate as an operator without declaration.  Macros should be allowed to detect this particular syntax.  That way they can expand it as if it were function sugar.

We could use Haskell's backtick syntax, but backticks seem far too valuable as quotation operators.  Backslash is are enough as an operator.
