I want it to be easy to run untrusted Amalog code.  Code causes harm by performing IO, using too much memory, performing too many computations, taking too much time.  There should be ways to prevent each of these.  In Mercury, IO requires access to a special value.  A predicate without access to this value cannot perform IO.