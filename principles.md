# Principle of Experiment

Base language design decisions on the results of objective, repeated experiments whenever possible.  Give greater weight to experiments conducted in "real world" scenarios rather than micro-experiments that try to simulate one small aspect of software development.

# Principle of Religion

If a style convention doesn't matter (less than 10% difference in productivity between choices), adopt one arbitrarily and make the others illegal.  The amount of productivity lost through argument and mixed conventions far outweighs any benefits.

Examples might include tabs vs spaces, indent size, identifier naming style, brace placement, if-else layout, etc.

# Principle of Legibility

Weight design decisions 10 to 1 in favor of reading code vs writing code.  Developers read code far more often than they write it.  We should optimize for the common case.

# Principle of Performance

Give runtime performance the lowest priority among all design factors.  Because of fast CPUs and cheap cloud servers, runtime performance is rarely worth the associated development cost.  When performance does matter, code becomes complex and confusing anyway or that component is rewritten in C.  In neither case do the language's typical semantics matter much.

# Principle of Progress

Don't halt a developer's forward progress for mistakes which can be resolved later.  Software development is a process of experimentation and discovery.  The flow of exploration should not be broken lightly.

Following this principle naively incurs substantial technical debt, whose future payment also halts progress.  Tools must also make it easy for a developer to find and pay this debt when she's ready.
