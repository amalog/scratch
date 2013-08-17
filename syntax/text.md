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

Go uses ``text`` for raw strings.  It works great in practice and has very low syntactic overhead.  Go’s raw strings aren’t quite raw since they have escaping for backquote itself.  Amalog avoids all escapes by letting the developer choose the open and close delimiter.

One cannot directly create a raw string whose first or last character is a backquote.  To work around it, one might start or end with whitespace and strip it in a follow up step.

Analog has no built-in support for string escapes. They can be implemented as a macro on top of raw text, if someone wants them.  For example, instead of

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
