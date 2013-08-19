(See Haskell section for some lessons it taught me)

In my view, modules are a glorified means of facilitating copy and paste.  There’s useful code somewhere in the world and I want to use parts of it in my project.  For example, instead of visiting http://goo.gl/QFPJl3 then copying all clauses from `answer/1` then pasting them into my code, I should be able to just write

    import ‘http://goo.gl/QFPJl3’ [answer/1]
    
    main
	    answer Answer
	    say Answer

For Prolog variants, the smallest level of code reuse is a clause.  So I should be able to say “there’s a database of code over there; I want these clauses; use them to augment my database like this”.  That suggests the following hooks:

  # convert module name (a term) into a database value
  # select clauses from that database
  # transform the clauses (sort of like macro expansion)
  # assert those clauses in my database

Semantically, adding clauses to my database just adds a copy of those clauses.  Compilers might optimize that with copy on write or immutable data structures or something fancy.  Semantically they behave as if the user manually copied the code and pasted it into his database.

Of course, module systems were created to avoid some of the problems of straight copy and paste.  As far as I can tell, the big one that really needs to be addressed is code dependencies.  If I copy a clause which calls other code, I have to be certain to copy that other code transitively.  That might require loading other modules, etc.  Of course, on another level the copy-paste model helps with dependencies.  When importing from a source database, first build that database (recursively processing imports, etc) then from that database, copy the clause we’re importing.  Also copy from that database the goals referenced in the clause.  Because of copy-paste, we know that the necessary clauses are already in the source database.  If not, the source database has a dependency problem which is beyond the scope of module imports to fix.  How does this interact with `no_such_predicate/1`?

A module should also be able to export clauses whose definition isn't entirely complete.  For example module `foo` might have a clause for `bar/1` which calls `baz/2` even though `foo` has no predicate `baz/2`.  `foo` is relying on the importing module to supply that predicate.  This similar to the notion Moose (a Perl library) has for roles.  The exporting module declares which predicates the importer must supply so that it can check at import time that its requirements are met.

It’s worth thinking about autoloading systems here.  Perl, Prolog and others have autoload systems whereby they automatically search for code if you use code that doesn’t yet exist.  These are very helpful for rapid development because one’s not interrupted fiddling around with import statements, etc.  However, when I call `foo/1`, it’s not entirely clear which of hundreds of different `foo/1` predicates I’m referring to.  In practice it almost always works as the developer expected and does help productivity.  It should not be built into the language’s notion of modules, but the language should be powerful enough to allow others to write it.  It’d be nice if calling an autoloaded predicate automatically updated the code’s import statements to make it official.  Many IDEs do that automatically, which is a good balance between rapid prototyping and precision.

Perhaps autoloading is best implemented with a more fundamental mechanism: `no_such_predicate/1`.  This predicate is called when a matching predicate doesn’t exist in that database.  It’s similar in spirit to Smalltalk’s `doesNotUnderstand` method.  Amalog’s prelude could export a `no_such_predicate/1` implementation if one doesn’t already exist.  In development mode, the default could try autoloading.  In production, the default could raise a condition.

The idea of autoloaders rewriting a file’s import section makes me wonder if imports should be done as facts in the database rather than directives with side effects.  Perhaps when encountering an import fact, the side effects happen but one can also assert an import fact to update that part of the code.  When serializing a database, all import facts are recorded at the top of the file.  One might do the same thing with a single module fact.  It’s just an attribute of a database.  That gets you something like this:

    module foo [bar/1, baz/2]
    import something [stuff/2]
    import another [thing_1/0, thing_2/0]
    
That also makes me wonder if a module’s export list should be recorded as `public/1` facts like

    public bar/1
    public baz/2
    
At this point, we end up with too many reserved fact names and should probably consolidate into a single `meta/N` fact to address them.

    meta module foo
    meta public bar/1
    meta public baz/2
    meta import something stuff/2
    meta import another thing_1/0
    meta import another thing_2/0

Of course, a user writes the nice, sugary syntax and it's expanded into the verbose, explicit syntax (although, in that case, you might as well use the original, nice names).  This arrangement lets one query a module to ask things like “what is your name?”, “what predicates do you export?”, “what predicates do you import from elsewhere?”, etc.

One of the biggest headaches with using modules in large projects is what developers have come to call “dependency hell” or “version hell” in which it becomes a burden to manage which versions of modules are required.  In reality, each version of a module is a completely different module.  In that sense, developers just need to be more explicit about which versions of a module they request.  That suggests an import mechanism like:

    import foo v1.3.5 [bar/1]

By specifying the precise version number, it’s always clear which code should be used.  One might even do

    import foo v1.3.5 [bar/1]
    import foo v2.0.1 [baz/2]

Of course, if `bar/1` and `baz/2` each call a predicate internal to `foo`, we have to be sure to import both versions and rewrite `bar/1` and `baz/2` to call the correct version.  Maybe that’s going too far.  It gets awfully tiresome to write version numbers everywhere.  Then they all must be changed during an upgrade.  That suggests we should have a level of abstraction so that I can specify/change a version number in one place and have it propagate everywhere.  Dart’s pub system takes this approach with the `pubspec.yaml` file.  However, the term describing a module to be imported is already a layer of abstraction.  Step #1 above can do whatever it wants to convert the term into a database value, include looking inside an `amalogspec.yaml` file, or whatever.  Then one might just do

    import foo(v1) [bar/1].
    import foo(v2) [baz/2].

Both `foo(v1)` and `foo(v2)` are resolved to the proper code at the proper version.  There’s still the question of renaming internal predicates, but that’s an implementation detail.

When thinking about the copy-paste approach to modules, be sure to think about importing a predicate which dynamically changes its definition over time.  For example, my `library(delay)` module in Prolog adds clauses to the `delay/1` predicate on certain invocations.  We need to make sure that sort of dynamic code still works.  That’s one of the greatly powerful features of Prolog variants.  I suppose that as long as `delay/1` were module-local and its `assert/1` calls modified only the local module’s database, it would work fine.

It seems that importing a module is really just a way to call a predicate in the imported module which takes one’s current database and produces a new database.  It’s similar in spirit to the way that Perl implements modules by having each module define an `import` method.  That method can perform arbitrary computation to carry out the import.  Having a predicate that maps from one database to another is a natural extension of that idea.  On the plus side, Perl's enormous flexibility in this area has spawned a whole ecosystem of experimental module tools (`Exporter`, `Sub::Exporter`, `Moose`, etc).  So perhaps

    import foo [bar/1] random stuff
    
creates a database from `foo` (see above) named `Foo` then calls

    Foo:perform_import [[bar/1] random stuff] DB0 DB

There will probably be helper modules which export useful `perform_import/3` predicates (or clauses) so that each module doesn’t have to recreate the wheel.

Building on the `perform_import/3` idea, one might define a module like

    module something
    import exporter
    
    exports foo/2
    exports bar/1
    
    foo a b
    bar x
    
The `exporter` module creates a `perform_import/3` predicate in the database representing module `something`.  That predicate queries `export/1` to determine which predicates should be exported to those modules who import `something`.

Under this architecture, modules can perform all kinds of useful work on behalf of their importers.  It also leaves it up to the exporting module to perform the exporting.  The exporting module certainly knows more about exporting its predicates that any generalized module system could.