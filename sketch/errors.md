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
