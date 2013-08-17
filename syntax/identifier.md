Allow identifier names to end with a punctuation character.  This can be helpful for denoting side effects (`foo!`) and semidet predicates (`foo?`).  Other conventions seem likely to arise:

  * `foo+` : "multi" in Mercury's sense (pneumonic: like regex `+`)
  * `foo*` : "nondet" in Mercury's sense (pneumonic: like regex `*`)
  
Encoding the mode in a name removes some compiler discretion.  I don’t like that.  Think carefully before using trailing punctuation in the core library and establishing it as a precedent.  I’m much more comfortable denoting side effects this way.
