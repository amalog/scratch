Some people don’t like Prolog’s cut (`!/0`) predicate.  For example, Mercury doesn’t have that operator at all.  The opposition has good theoretical reasons, but cut seems quite practical as an optimization despite all that.  Certainly it can be misused, but that seems like a poor reason to eliminate it.  It would be better to write tools which warn about these poor behaviors.

I wonder if it’s worthwhile to have a predicate that blocks cut from cutting any further.  Perhaps a `cut_barrier(-ChoicePoint)` predicate.

    call Goal
        some_goal        
	    cut_barrier _ // !/0 stops here
	    Goal          // seek solutions to Goal

Ancient Prologs, and some modern, have first class choicepoints and a `cut_to/1` predicate to cut all choicepoints before a given one. These are traditionally called ancestral cuts. `!/0` is obviously a special case which can be implemented with this underlying machinery. Perhaps `!/0` should just be a macro on top of `cut_to/1`. Try writing it and make sure it's possible.

If we have `cut_barrier(-ChoicePoint)` and `cut_to(+ChoicePoint)`, can `-> ;` be implemented as a macro? Should it be? Is there a reason to have if-then-else as a fundamental control construct?

First class choicepoints seem like a no brainer. It's always good to give the language access to meta information so that powerful extensions can be built on top of it.
