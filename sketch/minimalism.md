I want Amalog to be a minimal language.   Someone wanting to implement the language should only have to implement a parser and a few primitives.  Everything else is built using on the primitives via predicates and macros.

This makes it easier to have many different implementations.  That allows one to use Amalog anywhere that it’s useful.  It also makes it easier to experiment with the language since improvements don’t require changes to the underlying implementation.

When I speak of “minimalism”, I don’t mean that in the strictest theoretical sense.  In that case, we get a one instruction set computer.  Being a little more generous gives us only sequence, selection and iteration.  Both of these are too minimal.  I mean that we have a very small, practical core language.  It shouldn’t have features which can reasonably (for some definition) be implemented in terms of others.

When I speak of “minimalism”, I don’t mean that in the [strictest theoretical sense](http://cs.stackexchange.com/questions/991/are-there-minimum-criteria-for-a-programming-language-being-turing-complete).  In that case, we get a [one instruction set computer](https://en.wikipedia.org/wiki/One_instruction_set_computer).  Being a little more generous gives us only [sequence, selection and iteration](https://en.wikipedia.org/wiki/Structured_program_theorem).  Both of these are too minimal.  I mean that we have a very small, practical core language.  It shouldn’t have features which can reasonably (for some definition) be implemented in terms of others.

The [structured program theorem](https://en.wikipedia.org/wiki/Structured_program_theorem) is an interesting framework for thinking about a language.  In Prolog variants we could categorize constructs along these lines:

  * sequence
    * `,/2`
  * selection
    * unification
    * `!/0`
    * `*-> ;`
  * iteration
    * recursion
