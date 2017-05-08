# Example Driven testing

As mentioned in the [comments document](../syntax/comments.md), I'd
like comments to be able to include examples so that a "For example"
section of the documentation is run as a test suite and verified
to be accurate.

Examples in comments aren't the main way to do testing, but they're an
easy and particularly helpful one; especially for relational
predicates.

# Generating mode tests

If I declare a test like `plus(1,2,3)` then the `plus/3` predicate
should produce the values indicated in all acceptable modes.  That one
declaration generates tests like the following:

```
plus(1,2,X), X==3.
plus(1,X,3), X==2.
plus(X,2,3), X==1.
```

It might also generate tests for modes which generate multiple
solutions. We'll have to be careful in those cases that generating
solutions reaches the desired solution in finite time.  We'll probably
want a way to say "consider up to N solutions while trying to prove
this test true."

```
plus(1,X,Y), X==2, Y==3.
plus(X,2,Y), X==1, Y==3.
plus(X,Y,3), X==1, Y==2.
```

# Quickcheck testing

I definitely want to be able to describe properties which hold between
different relations and have Amalog generate random tests cases for me.
Similar to Haskell's QuickCheck library.

# Fuzzing

Given a collection of manually written test cases, I'd like the
machine to generate random variations of those tests cases.  This is
different than QuickCheck testing because it's not designed for
testing properties.  It's designed to broaden the scope of an existing
test suite and find combinations of values which trigger unexpected
behavior.

Communications of the ACM (around May 2017) had a good article about
fuzzing in MongoDB which follows this model.
