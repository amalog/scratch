(See Haskell section for some lessons it taught me)

In my view, modules are a glorified means of facilitating copy and paste.  There’s useful code somewhere in the world and I want to use parts of it in my project.  For example, instead of visiting http://goo.gl/QFPJl3 then copying all clauses from `answer/1` then pasting them into my code, I should be able to just write

    import ‘http://goo.gl/QFPJl3’ [answer/1]
    
    main
        answer Answer
        say Answer

For Prolog variants, the smallest level of code reuse is a clause.  So I should be able to say “there’s a database of code over there; I want these clauses; use them to augment my database like this”.  That suggests the following hooks:

  1. convert module name (a term) into a database value
  1. select clauses from that database
  1. transform the clauses (sort of like macro expansion)
  1. assert those clauses in my database

Semantically, adding clauses to my database just adds a copy of those clauses.  Compilers might optimize that with copy on write or immutable data structures or something fancy.  Semantically they behave as if the user manually copied the code and pasted it into his database.

Of course, module systems were created to avoid some of the problems of straight copy and paste.  As far as I can tell, the big one that really needs to be addressed is code dependencies.  If I copy a clause which calls other code, I have to be certain to copy that other code transitively.  That might require loading other modules, etc.  Of course, on another level the copy-paste model helps with dependencies.  When importing from a source database, first build that database (recursively processing imports, etc) then from that database, copy the clause we’re importing.  Also copy from that database the goals referenced in the clause.  Because of copy-paste, we know that the necessary clauses are already in the source database.  If not, the source database has a dependency problem which is beyond the scope of module imports to fix.  How does this interact with `no_such_predicate/1`?

A module should also be able to export clauses whose definition isn't entirely complete.  For example module `foo` might have a clause for `bar/1` which calls `baz/2` even though `foo` has no predicate `baz/2`.  `foo` is relying on the importing module to supply that predicate.  This similar to the notion [Moose](https://metacpan.org/pod/Moose) has for roles.  The exporting module declares which predicates the importer must supply so that it can check at import time that its requirements are met.

It’s worth thinking about autoloading systems here.  Perl, Prolog and others have autoload systems whereby they automatically search for code if you use code that doesn’t yet exist.  These are very helpful for rapid development because one’s not interrupted fiddling around with import statements, etc.  However, when I call `foo/1`, it’s not entirely clear which of hundreds of different `foo/1` predicates I’m referring to.  In practice it almost always works as the developer expected and does help productivity.  It should not be built into the language’s notion of modules, but the language should be powerful enough to allow others to write it.  It’d be nice if calling an autoloaded predicate automatically updated the code’s import statements to make it official.  Many IDEs do that automatically, which is a good balance between rapid prototyping and precision.

Perhaps autoloading is best implemented with a more fundamental mechanism: `no_such_predicate/1`.  This predicate is called when a matching predicate doesn’t exist in that database.  It’s similar in spirit to Smalltalk’s `doesNotUnderstand` method.  Amalog’s prelude could export a `no_such_predicate/1` implementation if one doesn’t already exist.  In development mode, the default could try autoloading.  In production, the default could signal a condition.

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

Of course, if `bar/1` and `baz/2` each call a predicate internal to `foo`, we have to be sure to import both versions and rewrite `bar/1` and `baz/2` to call the correct version.  Maybe that’s going too far.

It gets awfully tiresome to write version numbers everywhere.  Then they all must be changed during an upgrade.  That suggests we should have a level of abstraction so that I can specify/change a version number in one place and have it propagate everywhere.  Dart’s pub system takes this approach with the `pubspec.yaml` file.  However, the term describing a module to be imported is already a layer of abstraction.  Step #1 above can do whatever it wants to convert the term into a database value, include looking inside an `amalogspec.yaml` file, or whatever.  Then one might just do

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

By treating modules as completely isolated data containers (just database values), we should be able to realize some efficiencies for loading code in parallel.  For example, we could load all import modules in parallel. After they've all loaded, we can call `perform_import` serially to handle the actual imports.


I'd like to be able to define a module whose definition is spread out among several files.  Go does this and for large functions, I find it helpful to be able to have one file per public function and define all the internal helper functions inside it.  This also keeps the file size reasonable and often makes it easier to navigate around.  Smalltalk variants are able to completely abandon textual relationship between classes and methods because they view code inside an image.  That's great, but it usually requires special tools.  Programmers love the editors they already have and using a language shouldn't require using a special editor.

## Metadata

It seems useful to have a way of tracking metadata about predicates.  For example: mode, determinism, documentation, argument types, etc.  I don't presume to know a priori what kinds of metadata users will want to associate with their predicates.  Taking it to the extreme, that suggests that each predicate should have a meta database associated with it.  Predicates in that "metabase" convey information about the predicate.

Imagine a predicate like this (made up syntax):

    // counts the number of columns in a CSV line
    column_count +CSV:atom -Count:integer is semidet

given that definition, the "metabase" for `column_count/2` might have these entries:

    types atom integer

    mode in out semidet

    summary 'counts the number of columns in a CSV line'

Of course, that assumes that `column_count/2` is a first class entity which can be referenced and whose metabase can be obtained somehow.

Maybe this can be built on lower level infrastructure by having metadata providers define facts for a `metabase/2/` predicate.  So we'd have

    metabase column_count/2 ColumnCount2Metabase

Where ColumnCount2Metabase is a first class database value with the contents described above.

Are there use cases for having a metabase for arbitrary terms?  Clojure allows metadata like that.  It'd be worth reading about and seeing how often it's used in practice.


## Versioning

Software projects of any significant scale require specific versions of specific modules.  As described above, the module import mechanism allows one to assign symbolic names to a specific version of a specific module.  For moderately large projects, one can specify version numbers by hand.  As projects grow larger still, it becomes unwieldy to manually find module versions that meet all constraints.  Many language communities have concluded that tools should solve those constraints and cache the solution in a project's repository so that all developers can work with the same module versions. [Ruby Bundler](http://bundler.io/) seems to be the defacto, industry leader.  In some cases, the tool can't resolve all constraints, so it asks for guidance from a developer.

Because version resolution is just a constraint problem, it seems natural to allow constraints to be arbitrary Amalog rules.  A solution is just the first (or best) solution to those constraints.  There would be sugar for the most common constraints, just as Bundler has `~>` and friends.

There's [some debate](https://groups.google.com/forum/m/#!msg/golang-nuts/sfshThQ_wrA/6QVvQ5GlctEJ) on the Go mailing list about versioning.  Go provides no support for it natively.  In the thread, several people say the problem shouldn't be solved or can't be solved.  The naysayers mostly seem to say, the problem can't be solved in all cases, so why bother solving it for any practical cases.  However, experience with Bundler and friends suggests that it can be solved for nearly all real world use cases.


## Execution

I like the idea of each module being a completely isolated database.  When a program is loaded, all module imports are processed and the end result is a single `main` database.  This database has a single `main` predicate as the entry point.  This is like compiling a static binary in which all libraries have been incorporated.  It can stand on its own.

Having a single entry point (`main` predicate) also makes it easier to walk the code tree and perform various analyses.  [Dart](http://www.dartlang.org) takes that approach so that tree shaking works nicely.

## Naming

If possible, use a different naming convention for modules and the packages through which they're distributed.  Hackage is a good example.  The package `network-bitcoin` contains the module `Network.Bitcoin`  This makes it clear when I'm talking about the module and when the package.

Contrast that with CPAN.  Packages and modules have an identical naming convention.  I just wrote a Makefile.PL in which I specificed a requirement on the module `URI::QueryParam` because I thought the file wanted module names.  It actually wanted package names (needing `URI` in this case), but similar formatting of the two confused me.

## Complete Isolation

Now for something completely different.  Above, I mention the value of having each module as a separate database.  However, nearly all the details I described are premised on importing or copying code from one database to another.  Once you do that, they're no longer separate.  What if imports couldn't happen at all?  What if one could only call a predicate in a second module by specifying the second module and the name of the predicate.

Go packages work this way, so it can teach us some positives and negatives of the approach.  The function `Println` is in the `fmt` package.  Calling that function in Go looks like this:

```go
import "fmt"
...
fmt.Println("Hello")
```

It works approximately like this:

  * `import` declaration loads code from a collection of files
  * `import` declaration creates a single identifier (`fmt`) in the local scope
  * one calls functions via that identifier

Benefits include:

  * Reading code is fairly pleasant
  * One is reasonably certain which function is being called
  * One only needs to remember a short list of package identifiers instead of a long list of function-package tuples
  * No need to rename imported functions to avoid name collisions


Costs include:

  * Minor repetition with `foo.` in front of "foreign" functions


Node.js modules also assign a local identifier to each imported module.  Functions are called via that identifier.  For example:

```javascript
var circle = require('./circle.js');
console.log('Area is ' + circle.area(4));
```

Both Go and Node make the mistake of overloading `.` for module dereference and field access.  This means trouble when on wants a local variable with the same name as a module identifier.  I find this a frequent annoyance in Go.  Imagine a module "zoo/cat" yielding `cat` as the module identifier.  My program is obviously working with cats and might want to do something like `_, cat := range cats` but then calling `cat.Foo()` tries to call a method on the variable rather than call a function inside the `cat` module.

### Modules as Interfaces

The public predicates of a module define an interface.  For example, a module named `set` implementing a set data structure might have predicates `insert/3` and `remove/3`.  One should be able to swap in a new set implementation (maybe `hset` using hashes) by changing just the import statement.  This is possible both when modules import symbols and when modules are referenced by an identifier.  However, experience suggests that importing symbols often leads to defensive API design in which exported symbols are given unlikely prefixes to avoid name collisions.  For example, we might end up with `set_insert/3` and `set_remove/3`.  When I switch to the `hset` implementation, I have to rename those to `hset_insert/3` and `hset_remove/3`.

In languages that identify modules by reference, this convention doesn't arise.  Library authors know that their users are unable to create name colisions.  Any attempt to write code like `hset.hset_insert/3` immediately makes one cringe, so library authors don't do it.  That makes it easy to swap out a new implementation by just changing the import statement.

### Imports as Macros

If we have completely isolated modules and a library wanted to implement something that looked like imports, it could create a local predicate which invokes a predicate in another module.  To make up a syntax:

```
import module_name [hello/0,bye/1]
```

could expand into

```
import module_name

hello
    module_name:hello

bye X
    module_name:bye X
```

### Module Identifiers as Variables

The Node example (above) shows that modules (or a reference to them) are stored in normal variables.  Dart appears to do something similar.  Dart's [deferred loading](https://www.dartlang.org/docs/spec/deferred-loading.html) mechanism suggests why that might be a good approach.

Let's make the following assumptions for Amalog:

  * modules are just database values
  * module identifiers are just normal variables

Then we get deferred module loading through standard deferred value mechanisms on variables.  For example, the Prolog library [spawn](http://www.swi-prolog.org/pack/list?p=spawn) allows one to perform a computation lazily or in the background.  The program only blocks when that computation's value is needed.  All of this machinery is hidden behind a variable which represents the value.

That might give us Amalog code like this:

```
import fancy_library Fancy

main
    Fancy:hello "world"
```

If `Fancy` is a singleton variable, then normal warnings about singletons tell us when a library is not being used.  One could invoke `import fancy_library _` to indicate that the package is being loaded for its side effects.


## Package Manager

It seems like every language has a package manager or some canonical way of downloading and using packages from the web.  [Edward Yang](http://blog.ezyang.com/2014/08/the-fundamental-problem-of-programming-language-package-management/) has some insightful thoughts on the problem of package managers and summarizes various approaches for solving those problems.

## Try to be Declarative

Most of my proposals above read too much like imperative code: "do this, do that, side effect here, etc"  I really want something more declarative.  Saying `use foo` instead of `import foo` would make it look more declarative but the semantics still seem too imperative to me.

What are the relations at play with interconnected modules?  How can those relations be declared?  How might we want to query those relations?

## Ditch Modules Completely

This idea [has been articulated](http://erlang.org/pipermail/erlang-questions/2011-May/058768.html) by Joe Armstrong and [discussed at length](http://lambda-the-ultimate.org/node/5079).  It has a certain appeal.  Of course, the highest level of code reuse in Amalog would be the clause, not the predicate.

Give this some thought.  On initial inspection it sounds like a nice simplification.  Do we lose anything by simplifying this far?

The most obvious "key-value database of all functions" is the web.  Keys are URLs; values are their content.

Similar ideas in this space are:

* [open wiki-like code repository](http://lambda-the-ultimate.org/node/3744)
* [escape from the maze of twisty classes](http://lambda-the-ultimate.org/node/4493)

### Semantic Web of Code

Imagine the semantic web.  It includes billions of statements.  Some of them are true, others are blatantly false, many of them contradict each other.  To get something useful, I accept a subset of them into my database.  Then I can query these facts and derive conclusions.

This idea of a language without modules is similar.  There would be thousands of clauses, each claiming to be a useful rule.  I choose a subset of those rules and add some rules of my own to create a program.

We also need a something like semantic web schemas so that clauses can agree on what they're talking about.  For example, a "person" in the semantic web could be a "http://xmlns.com/foaf/0.1/Person" or a "http://schema.org/Person".  It's useful for facts to agree on which "person" they're talking about.

So perhaps a "stack" (named with a URL like 'http://amalog.org/data/stack') has certain semantics and data layout.  Clauses wishing to implement or build on those semantics work with terms whose functor is 'http://amalog.org/data/stack'.  Of course nobody wants to read or type those URLs so perhaps developers specify a short identifier which dereferences to the full URL (maybe 'data:stack', in this case).

It's important that a compiler/interpreter be able to fetch all dependencies of a clause that we call.  We must be certain that we have all the code we need for execution.

Privacy can be addressed through naming conventions.  Anyone can use clauses they find in the wild.  If the name suggests privacy (leading underscore?) the original author reserves the right to remove/modify/desecrate that clause at any point.

How should clauses be referenced?  I don't really like URLs for this (even with shortened identifiers) because I still have to decide what the name is.  Perhaps some sort of content-addressable storage in which the clause's code dictates the name.  Then I can write a clause or two and toss them into the pile.  As with other content addressable storage, we need a way to point at a root node from which all other pieces can be found.  I just publish a name (which points to a content address) if I want people to conveniently use the thing I made.
