# What I like about Haskell

Haskell is a neat language.  This section describes what Amalog can learn from it.

I like how often Haskell catches my silly mistakes at compile time.  I don’t have to hope that I trigger a faulty code path during testing.  It brings the problem to my attention before it breaks in production.  On the flip side, Haskell is a little too aggressive: many false positives and error messages interrupt flow.  *For Amalog, I want a tool that catches errors without false positives and it only runs on demand*.  That lets flow continue smoothly but many errors are easily caught before production.  Something like Erlang’s dialyzer based on success typing seems like a good solution.

## Typeclasses

  * A function such as `length . show` automatically works on all instances of the `Show` typeclass
  * It works as expected with data types I haven’t even thought of yet. That’s great for code reuse
  * I can use functions from different typeclasses and my code automatically requires that a type implement all of them
  * Because the function name is always `show`, for example, I only have to remember one name regardless of which type I’m working with
  * I like the structure that instance declarations provide
    * One sees at a glance that a series of functions was created to fulfill a typeclass’s interface
    * Go doesn’t require a type to opt-in to an interface, but for non-trivial interfaces an implementer does all the same work anyway, it’s just disorganized
    * The probability of accidentally implementing the right interface, and thus benefiting from the lack of instance declarations, is exceedingly small
  * I don’t like having to implement an entire instance even if the functions I want to use only call a subset of the interface.  Go wins here.
  * *For Amalog:*
    * Let developers create new clauses for existing predicates.  Like `multifile` predicates, but less global.  One should have to explicitly import these clauses for them to take effect in a module.

## Modules

  * importing specific functions (a whitelist)
  * importing all functions except some (a blacklist)
  * importing all functions but giving them a prefix
  * accidentally importing functions with the same name is an error
  * *For Amalog:*
    * import entire predicates with a whitelist & blacklist (error if name/arity already exists)
    * import qualified or not (error if name/arity already exists)
      * `import foo [stuff/1] under bar` creates `bar_stuff/1` predicate
    * import extra clauses to augment an existing predicate
      * `import foo [stuff/1 clauses]`
      * `import bar [stuff/1 clauses]`
      * local predicate `stuff/1` has local clauses, then foo’s clauses, then bar’s clauses
    * maybe a module declares whether its predicate should import in isolation or just add its clauses to an existing definition (if there is one)
