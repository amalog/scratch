# Spec

A raw text token begins with one or more grave accent characters (`U+0060`).  It concludes with the same number of the same character.  All unicode characters between these markers are part of the text content.  No escaping is performed.

Double quoted strings are a syntax error. They are reserved for future use.


# Examples

Most raw text content uses a single backquote:

    X = `someone’s raw text`
    
If the content must contain a backquote, two backquotes are used as delimiters:

    Go = ``fmt.Println(`some “quotes” in embedded Go code`)``
    
Embedding a Python multiline string:

    Python = ````
        x = ```
            This is a lengthy piece of text
            embedded in Python, embedded in Amalog
        ```
    ````

# Reasoning

Go uses backticks for raw strings.  It works great in practice and has very low syntactic overhead.  Go’s raw strings aren’t quite raw since they have escaping for backquote itself.  Amalog avoids all escapes by letting the developer choose the open and close delimiter.

One cannot directly create a raw string whose first or last character is a backquote.  To work around it, one might start or end with whitespace and strip it in a follow up step.

Amalog has no built-in support for string escapes. They can be implemented as a macro on top of raw text, if someone wants them.  For example, instead of

    “one\ntwo\nthree”
    
we’d have

    e`one\ntwo\nthree`
    
which expands into

    `one
    two
    three`.
    

# Use Cases

The key feature of raw strings is that there’s no escaping inside them.  This lets users include content like source code, regular expressions, HTML, etc. without worrying whether they’ve accidentally triggered an escape.

Macros use raw strings when embedding foreign languages inside Amalog (similar to quasiquotation in other languages).

# Scratch

## Double-quoted text

I like Haskell's overloaded strings.  They've proven quite flexible and productive as the Haskell community has evolved their implementation of text types.  Perhaps it could be done in Amalog by expanding a double quoted string into a predicate call:

```
foo "hello, world"
```

becomes

```
text_term `hello, world` X
foo X
```

Developers add clauses to `text_term` to define how raw text is converted into their own term format.  Partial evaluation and simplification reduces the run time cost of backtracking over all possible `text_term` clauses.


## End of line text

For short DSLs (like math notation), it would be convenient to have raw strings which extend to the end of a line.  Many natural languages use the [quotation dash](http://en.wikipedia.org/wiki/International_variation_in_quotation_marks#Quotation_dash) for such purposes.  We don't want to require developers to type Unicode characters (`U+2015`), so we could use two adjacent hyphens.

```
math -- X = 27*Y + 3
```

which is equivalent to

```
math `X = 27*Y + 3`
```

Maybe the benefits aren't substantial enough to justify having this special syntax.  It's worth considering.  An end of line string also needs to consider how end of line comments work.  Should the two be unified somehow?  Semantically an end of line comment and an end of line string are different.  The former has no influence on execution while the latter does.
