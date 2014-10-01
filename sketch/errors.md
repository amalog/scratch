# Error Handling

I don't think exceptions are fundamental enough.  They can be implemented in terms of condition and restart.  I need to spend more time working with Common Lisp's condition and restart system to understand if it's really as flexible and productive as I think it is.  See my [previous thoughts](http://blog.ndrix.com/2013/02/programming-for-failure.html) about error handling.


Joel Spolsky makes [some reasonable arguments](http://www.joelonsoftware.com/items/2003/10/13.html) that exceptions (and by extension, condition-restart) should be considered more harmful than GOTO statements.  Besides his criticism of exceptions, he raises some interesting questions about how errors should be handled:

  * how well does the error handling mechanism get out of the way
    when one is prototyping or otherwise doesn't care about errors
  * how well does error handling compose (see `g(f(x))` example)


Condition and restart seems like the same failure handling mechanism that has developed repeatedly in complex systems in the real world.  Businesses have managers to whom problems are delivered; they can address them with a broader perspective on the businesses needs.  Communities have elders/chiefs/judges to whom difficult questions can be brought for resolution; they address the problem with a broader level of experience/knowledge than those facing the problem.  I vaguely recall that our brains have a similar, multi-tier architecture for handling unexpected/novel inputs.

The fundamental idea behind condition-restart seems simple.  When code encounters a circumstance it can't deal with, it asks someone else for additional information.  That information resolves the circumstance into something it can deal with.

It's interesting to note that in Common Lisp, handlers can modify the condition on its way up the call stack.  For example, [this tutorial](http://chaitanyagupta.com/lisp/restarts.html) modifies the condition by adding a line number.  It doesn't stop the condition; just adjusts it a little before it proceeds upward.  That same tutorial suggests value in allowing handlers to track state (count signals received, for example).

Kent Pitman [describes condition-restart](http://www.nhplace.com/kent/Papers/Condition-Handling-2001.html) as a protocol by which independent pieces of code may communicate.  This suggests that a function and its ancestral callers can be thought of as independent nodes in a network.  In the general case, they're working together and must cooperate.  The common case is for ancestor to communicate a single message to the function (calling it) and the function communicates a single message back to the ancestor (returning a value).  Because that's the common case, nearly all languages provide convenient support for it.  Common Lisp acknowledges that in certain occasions, the communication requires more than a single message.  This is conceptually similar to the difference between static web pages (single request and response) and dynamic web pages (request + AJAX requests).

Kent also sees value in asking the condition what restarts are acceptable.  This kind of reflection allows a top-level, for example, to ask the user how he wants to handle a condition.  I imagine this would be quite helpful during debugging and prototyping.  Ideally, the list of acceptable conditions can be inferred from the context in which the condition is signaled.  I believe this is done in Common Lisp with `restart-case` which can signal the error and perform a switch on the resulting restart.  The switch cases are used as the list of acceptable restarts for that condition.

In Prolog, one can think of an exceptional situation as one in which the program tree has several branches and the code is not sure which one it should take.  A restart provides sufficient information that the code can choose one of those branches.  Prolog variants encounter similar scenarios all the time and they just explore each branch and backtrack if it's wrong.  In that circumstance, errors are handled by teaching Prolog what "wrong" means.  In many scenarios that works fine.  However, if one can't backtrack out of a branch (due to side effects, etc.), one must be certain which branch is the right one before pursuing it.

When code signals a condition, it's asking its ancestors in the call tree for help resolving the condition.  This is like asking the ancestors to evaluate a predicate `help_me(+Condition,-Guidance)` which binds `Guidance` to one of `go(Restart)`, `adjustment(NewCondition)`, `unwind_call_stack`, etc. or fails if it can offer no help.  This leaves open the question: how do the ancestors contribute to defining this predicate.  We could have each ancestor give its own definition of the predicate and evaluate those predicates from most specific to most general ancestor (as Common Lisp does).  We could have each ancestor contribute clauses to a dynamically scoped `help_me/2` predicate which is evaluated by the signaler.  Under that arrangement, we'd probably want clauses from the most specific ancestor to come before those from the most general ancestor.

Kent Pitman's paper (above) suggests an interesting idea that might be applicable in Amalog: instead of having an ancestor return a single restart, it could return a set of constraints which the branches must satisfy.  Choosing a single restart is a specific case in which the constraint is `Restart=foo`.  Although the generality and power of the idea is enticing, I'd have to see some real use cases for this before adopting it.

Should one who signals a condition be allowed to specify a default action to take if none of the call stack ancestors choose a restart for him?  The default might be to stop the program with an error message or it might be to guess at a reasonable way forward.

## A Walk through Failure Forest

*A parable of software error handling*

A grandfather, a father and a son were walking on a path through the forest.  As they walked, they dropped little stones remind them which path they had taken.  At one point, grandfather stops and tells the other two to continue without him, they can return to tell him what they discovered when their adventure is done.  Miles and many forks in the road later, the father tells the son to go on without him.  "Come back and tell me what you found, when your adventure is done", he tells his son.

The son continues forward on the path, following the guidance of rustic signs placed at forks in the road.  Sometimes the son encounters a fork without a sign.  If all paths look safe enough, he ventures down one path and backtracks when he finds a deadend.  At one fork, there is no sign and all paths forward look dangerous and questionable.  "What do I do?", wonders the son.

### GOTO

"Grandfather is probably lonely after all this time.  Forget the journey, I'll go back to him"  Jump!  The son is immediately back with his grandfather and forgotten everything about his journey.  They grandfather is startled nearly to death to see his grandson appear out of nowhere.  "Where did you come from!?  How did you get here?  Where's your father?"  "Hmm ... I don't know.  I'm not sure how I got here or where dad is.  Weren't we going to take a walk in the forest?"

### Exceptions

The son throws his hands in the air, abandons his backpack in brush and runs screaming back in the direction of his father managing to kick aside nearly every stone he left on his journey into the forest.  "What the heck is wrong with you?", asks the father puzzled.  "I saw a fork in the road and didn't know which way to go."  "Well, how did you get there?  Can you bring back to that spot so we can find the way forward together?"  I don't remember how I got there.  I only remember there as a fork in the road and all paths looked frightening"

"Don't worry son.  At least I kept my calm about me this time.  Do you remember the last time you ran screaming out of the forest and spooked me too?" "Yeah," said the son, "we both yelled all the way back to grandfather before we finally settled down".

### Conditions

Pulling out his trusty cell phone, he says, "I guess I'll call dad and see if he knows what I should do"  "Dad? I'm at a fork in the road without any signs.  Both paths look dangerous.  Which way should I go?"  The son describes what sees at the fork and the path he took to arrive here.  "I think you should go right, but maybe call your grandfather and see if he knows for sure"

"Grandpa? Which way should I go?", repeating the same descriptin he gave his father.  "Oh, I remember that route.  Back in '03 your grandmother and I ended up at that very same spot.  Now in those days, a three-headed COBOL lived to the left and that way was very unsafe.  I don't know what lives there now, but the right hand path smooths out a little further.  That's the way to go."

The son continues on his way through the forest, discovers a delicious patch of berries and calmly delivers some of the fruit to his father and grandfather who are still waiting patiently where he left them.

# Debugger

SWI-Prolog allows the debugger to run backwards in time.  When one encounters a failure, one can retry and pretend the failure didn't happen.  [Elm reactor](http://elm-lang.org/blog/Introducing-Elm-Reactor.elm) takes this even further by giving you a little time slider.  You can pause and rewind the debugger.

I really want this kind of functionality in an Amalog debugger.  I use it frequently when debugging SWI-Prolog programs.  Make sure the language allows for this sort of tooling.

I also want to have declarative debugging like Mercury has.  I haven't used that very much, but it seems like a specific application of a reversible debugger.  The reversing step is simply executed by a machine instead of with user interaction.
