Allow identifier names (aka unquoted atoms) to end with a punctuation character.  This can be helpful for denoting side effects (`foo!`) and semidet predicates (`foo?`).  Other conventions seem likely to arise:

  * `foo+` : "multi" in Mercury's sense (pneumonic: like regex `+`)
  * `foo*` : "nondet" in Mercury's sense (pneumonic: like regex `*`)
  
Encoding the mode in a name removes some compiler discretion.  I don’t like that.  Think carefully before using trailing punctuation in the core library and establishing it as a precedent.  I’m much more comfortable denoting side effects this way.

A language designer must decide whether to use `underscore_names` or `camelCaseNames` in the standard library.  Her choice establishes which identifier style the community adopts.  Experimental results are sparse, but they [consistently](http://whathecode.wordpress.com/2011/02/10/camelcase-vs-underscores-scientific-showdown/) [demonstrate](http://whathecode.wordpress.com/2013/02/16/camelcase-vs-underscores-revisited/) that reading camel case is more than 10% slower than reading underscores.  Underscores perform better in reading tests and camel case's main benefit is reduced typing cost.  Everything else is a wash, so I lean toward underscores (Principle of Experiment and Principle of Legibility).

Variable names have to start with an uppercase letter.  They're also designed to look different than atoms.  These two constraints suggest that camel case makes sense here.  Variable names are also far less likely to contain multiple words, so the productivity differences between underscore and camel case in this context should be smaller.  That again suggests that camel case may be the right style for variable names.

Amalog's Principle of Religion suggests that camel case atoms
should be illegal (unless quoted).  It suggests that underscores in variable names should be illegal.  That feels a bit extreme, but I have no objective reason for deviating from the Principle.
