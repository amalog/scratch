# Spec

A newline character followed by non-whitespace ends a clause (like a Prolog full stop).
Three adjacent newline characters end both the current term (clause) and current predicate.


# Examples


# Reasoning

Eliminates tokens which often cause SCM tools to show spurious changes.  For example, the trailing comma and period in Erlang and Prolog are awful for SCM tools and viewing patches.

Nearly all well-written programs, in any language, use indentation to represent the structure.  Punctuation typically recreates this exact same structure.  This redundancy requires developers to read and write extra characters without conveying any additional meaning.


# Use Cases

Most SCMs are language agnostic.  They perform simple-minded line-based diffs.  Under these conditions, a whitespace-sensitive syntax avoids spurious differences caused by changes to punctuation which don’t impact the program’s behavior.

# Questions

I wonder if I can improve on predicate calls with long argument lists.  For example in Prolog one might write

    some_goal(
        alpha,
        beta,
        gamma(1,2,3),
        delta(more,stuff,goes,here)
    ),
    etc.

There’s a lot of extra visual clutter redundantly conveying the same information as the indentation.  There’s also the perpetual problem of commas on the final argument.  Adding an extra argument requires one to modify the preceding line which makes diffs larger than necessary.  Alternate layouts require one to modify the first line instead; still making larger diffs.  What if I could write

    some_goal
	    alpha
	    beta
	    gamma 1 2 3
	    delta more stuff goes here
    etc

This technique:

  * eliminates redundant punctuation
  * moves complex arguments onto their own line
    * simplifying diffs that modify internal arguments
  * removes the final use for `,` which frees it to be used elsewhere

I need to develop a reasonable canonicalization guideline to determine when to use multiline arguments and when to use single line arguments.  Otherwise, we break isomorphism.

# Readable Lisp S-expressions

The [Readable Lisp S-expressions project](http://readable.sourceforge.net/) has developed a decent syntax for s-expressions.  It uses indentation for most nesting, allows parens for local nesting, supports infix operators without precedence.

Indentation and parens work about like I've described them above.

Infix notation converts this

    {a + {b * c}}

into

    (+ a (* b c))

The only missing feature is named arguments for terms.
