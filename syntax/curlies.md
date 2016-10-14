# Abstract

Use a syntax that's based on curly brackets.

# Rationale

It seems that nearly every successful programming language in the last two decades has
borrowed [B's syntax](https://en.wikipedia.org/wiki/B_(programming_language)#Examples)
with curly braces and indented blocks.  Since the presence or absence of curly brackets
is largely irrelevant, the [Principle of Religion](https://github.com/amalog/scratch/blob/f2098680ebc77ae266420e1f4875f42c781a69b5/principles.md#principle-of-religion)
suggests that it doesn't matter what we pick.  The [Principle of Legibility](https://github.com/amalog/scratch/blob/f2098680ebc77ae266420e1f4875f42c781a69b5/principles.md#principle-of-legibility)
suggests that we should pick a syntax with which most developers will be comfortable.
Roughly 8 out of 10 of [the most popular programming languages](https://blog.newrelic.com/2016/08/18/popular-programming-languages-2016-go/)
use a curly-based syntax.  We would need a substantial gain in productivity to choose
something else.  Since most code tools are already optimized for curly bracket syntax,
it seems likely that syntax might even have marginal productivity gains.

# Examples

Here's one thought on how an Amalog syntax with curly brackets might look:

```amalog
append(Prefix,Suffix,List) {
    Prefix = [];
    Suffix = List;
}
append(Prefix,Suffix,List) {
    Prefix = [X|Xs];
    List = [X|Ys];
    append(Xs,Suffix,Ys);
}
```

In this example, all unification is performed inside the clause body.  I don't know
if that's a good idea, but it creates longer clause bodies for the purpose of this
example.  The semicolons can always be omitted later [following BCPL's lead](https://groups.google.com/d/msg/golang-nuts/XuMrWI0Q8uk/kXcBb4W3rH8J).

# Term Syntax

We still want an Amalog program to be a simple list of terms.  That would require `foo(A,B){blah; etc}` to
be syntax for a term.  An obvious approach would be to add that as special syntax for a `clause/2`
term with the `foo(A,B)` part becoming the clause head and the `{blah; etc}` part becoming a `body(blah,etc)`
term representing the body.

Under that interpretation, `foo(A,B){blah; etc}` would be equivalent to the Prolog term:

```prolog
clause(foo(A,B),body(blah,etc))
```

Amalog would treat `clause/2` terms the same as Prolog treats `:-/2` terms.
