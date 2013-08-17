# Spec


# Examples


# Reasoning


# Use Cases

Factoring out boilerplate code

Quasiquotation can be implemented in terms of two fundamental operations: raw text content and macro expansion with access to in-scope variables (and their names).

Some language features which can be implemented with macros or quasiquotation:

  * creating new control structures
  * string interpolation
  * URL generation (with automatic escaping of params)
  * SQL generation (with automatic escaping of values)
    * building an abstract query which can be refined and composed
    * imagine building DBIx::Class queries by writing SQL queries rather than learning SQL::Abstract
  * HTML, CSS, JavaScript generation (with auto-escaping)

There should be only a single macro expansion predicate.  Most Prolog implementations have `term_expansion`, `goal_expansion`, `dcg_expansion`, etc. It gets confusing to know how they all interoperate, which comes first and whether any of it matters.  Perhaps a predicate like:

    macro_expansion +Context +Term -Expansion

where `Term` is the node that might need expanding.  `Context` is one of `clause`, `goal` or `argument`. `clause` is a top-level node.  `goal` is a node inside a clause surrounded by control structures (conjunctions, disjunctions, etc.).  `argument` is a node occurring inside a goal.  It probably makes sense to allow `Expansion` to be a list.  In clause context, that creates additional clauses.  In goal context, it creates a conjunction of additional goals.  In argument context, it creates extra arguments for the surrounding goal.  Think through other uses cases to be sure that’s the right way to go.

In most Prolog implementations, one must know in which order the macro expansion phases are executed (DCG before term_expansion?) and whether a single successful expansion stops the entire process.  That’s confusing and limits the power of macros.  One macro should be able to expand into other macros which are expanded again in turn.  When Amalog expands macros, it should repeatedly iterate the macro expansion steps until no more changes occur.  A given macro expansion rule may be run multiple times on a single term, so expansion rules should be idempotent.  This lets authors focus on writing the macro expansion and gives Amalog responsibility for applying those expansions to generate final code.

It’s vital that macros work well with the module system.  Macros should only apply when they're specifically imported.  Loading a module that uses macros internally should not affect any other code.  I’m inclined to say that importing a macro is just importing one or more `macro_expansion/3` clauses.  Only the `macro_expansion/3` definition present in a database is executed when reading terms into that database.  This should also apply to macros provided by Amalog itself.  They’re imported as part of a “prelude” module but behave just like all other macros defined by the user.

Carefully consider [this discussion](https://lists.iai.uni-bonn.de/pipermail/swi-prolog/2012/008055.html) about macro expansion to a fixed point.  Many bright people in the Prolog community address it and problems that can arise.  After a couple readings, I'm convinced that most problems are caused by macros with accidentally global reach or programmers who try to shoot themselves in the foot.  But don’t be so arrogant to assume that I’ve understood the entire discussion thoroughly.  Reread it a couple more times.

