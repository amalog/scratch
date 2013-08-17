# Spec

A comment is raw text content passed to the noop predicate `‘//’/1`.  A line that begins with `//` or a region delimited by `/*` and `*/` is desugared into an equivalent `‘//’/1` goal.  A line with `//` in the middle is desugared into the commented-call predicate `‘//’/2`.

Because of isomorphism, block comments must have an internal newline character to distinguish them from full line comments.  Both `//` and `/*` must have the same indentation as if code occurred in that location.


# Examples

A comment occupying an entire line:

    // the following line does something interesting
    do_something_interesting
    
Which is represented in a data structure as if it were written (pseudocode): 

    '//' `the following line does something interesting`
    do_something_interesting

A comment occupying the rest of a line:

    say `hello world` // be friendly with the whole world
    
Becomes a data structure as if it were written as (pseudocode):

    ‘//’ say`hello world` `be friendly with the whole world`

A block comment:

    /*
    This module does some important stuff.
    Use it often.
    */
    ...
    
As if it had been written (pseudocode):

    ‘//’ `
    This module does some important stuff.
    Use it often.
    `
    ...


# Reasoning

To preserve isomorphism, all comments must be retained as part of a program’s data structure.  Comments have one of three purposes:

  * describe a line (rest-of-line comments)
  * describe a “paragraph” (entire-line comments)
  * describe a predicate/module (block comments)
  
This semantic distinction is important for tools.  Block comments are also important for debugging and development.  Using entire-line comments for multiline comments requires heroics to maintain text justification, so they're not canonical form.

Comments embody two orthogonal ideas: arbitrary text blocks embedded in a program and no impact on code execution.  This design uses those two fundamental operations to implement the combined operation (former is raw text strings; latter is `//` noop predicate).

The specific characters used to dilineate comments aren’t particularly important.  Using `//` and `/*` with `*/` is the closest thing to a usage-weighted standard in the programming language industry (C, C++, Java, Go).  It prevents one from using `//` as an infix operator, but that seems like a reasonable price to pay.


# Use cases

## Inline tests

Rudimentary test cases might be included in comments, like this:

    /*
    True if the two lengths, in inches and centimeters,
    are equivalent.
    
    For example:
        inches_cm 12 30.48
        inches_cm 0 0
        inches_cm 97.345 247.2563
    */
    inches_cm Inches Cm
    // … define inches and centimeters relation

In development mode, a macro might convert those structured comments into code like this:

    :- inches_cm 12 30.48 -> true; warn `... fails`
    :- inches_cm 0 0  -> true; warn `... fails`
    :- inches_cm 97.345 247.2563 -> true; warn `... fails`

This leaves some tests in the documentation for users to read.  It also makes sure that the code always behaves exactly as the comments say it will.

## Loud Comments

Macros might make some comments (like `// TODO`) generate a warning in development mode.  This would draw attention to unfinished code or give insight into how often that particular code path is executed.

## Mode and Determinism Checks

Many Prolog programs document predicate mode and determinism in the comments like:

    atom_codes(+Atom, -Codes) is det.
    atom_codes(-Atom, +Codes) is det.

It would be helpful to convert those structured comments into assertions at development time.  I’m not sure whether modes and determinism are useful enough to escalate from documentation to a language construct.  Comments as terms leaves that decision open for the community to decide.

## Documentation Products

It’s often helpful to render code comments into HTML or LaTeX documentation.  By including all comments in a program’s data structure, these tools become very easy to write: read the program, generate output for each comment term.  Internal and external comments can be inferred by their location relative to other values (module comments vs rest-of-line comments).
