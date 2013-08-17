# Spec

A newline character followed by non-whitespace ends a clause (like a Prolog full stop).
Three adjacent newline characters end both the current term (clause) and current predicate.


# Examples


# Reasoning

Eliminates tokens which often cause SCM tools to show spurious changes.  For example, the trailing comma and period in Erlang and Prolog are awful for SCM tools and viewing patches.

Nearly all well-written programs, in any language, use indentation to represent the structure.  Punctuation typically recreates this exact same structure.  This redundancy requires developers to read and write extra characters without conveying any additional meaning.


# Use Cases

Most SCMs are language agnostic.  They perform simple-minded line-based diffs.  Under these conditions, a whitespace-sensitive syntax avoids spurious differences caused by changes to punctuation which don’t impact the program’s behavior.
