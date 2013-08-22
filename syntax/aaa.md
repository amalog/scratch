# Random, Unorganized Thoughts

# Punctuation

Punctuation is highly valuable in programming syntax.  It's easy to type, succinct to read visuallly different from surrounding text.  It also provides a recognizable subset of the characters available.

Many languages waste punctuation on rarely used operations like bitwise operators.  In a high level language that rarely twiddles bits, I'd much rather use word operators (xor, and, or, negate) for bitwise operations and reserve punctuation operators (^ & | !) for common operations.

## Research on visual design

Programming language syntax design is dangerously devoid of any scientific basis. We use curly braces because C did it many years ago.  It's been cargo culted along since then.  This section is an attempt to understand what research has been done into visual design and reading/visual comprehension as it relates to programming language syntax design.  Certainly psychologists and graphic designers have something to teach us here.

Each subsection here represents notes from a research article on the subject:

### Why Looking Isn't Always Seeing

Marian Petre, "Why Looking Isn't Always Seeing: Readership Skills and Graphical Programming", 1995.

There are 8 visual variables available for graphic design.  See "Semiology of graphics: diagrams, networks, maps" by Bertin J (1983).  They are:

  * horizontal position
  * vertical position
  * shape
  * color
  * size
  * brightness
  * texture
  * orientation

Programming languages consistently use horizontal position (indentation) to communicate structure.  They use vertical position to indicate sequence (although it's a little muddied since vertical position is also used to separate function definitions).  Languages like Haskell and Prolog use shape.  For example, Prolog variables start with an upper case and atoms start with a lower case.  I don't know of any languages that use color, size, brightness, texture or orientation; although some editors do.

His studies suggest that "secondary notation" (layout) is a vital distinction between novice and expert programmers (and electronics engineers).  This reminds me of the "commented paragraph" style I observe in many good programs, like this:

    // round out the frobnitz
    frobnitz_size Frob Size
    round Size Adjusted
    .
    // store frobnitz for later
    store_frobnitz File Frob Adjusted
    close File

In this case, vertical whitespace for layout communicates logical grouping.  Developers don't define a separate function for each group (which would convey the same grouping) because the mental overhead is too high.  Marian's studies suggest that layout plays an important role in comprehension and that poorly used layout can confuse readers.  Amalog's isomorphism prevents this secondary notation (bad) so it should provide a primary notation for conveying the same intent.  Maybe "newline, indent, newline, indent" is converted into a noop, layout predicate ("pilcrow/0" perhaps).

I wonder if Amalog's isomorphic form can adopt the best practices of experienced developers.  Although maybe it's too nuanced for an algorithm to reproduce.

One benefit of linear, textual representations of code is that they are "always amenable to a straight, serial reading, graphics requireds the reader to identify an approriate inspection strategy."  So, even when predicate definition order doesn't matter, it can be valuable to linearize it for the reader.

Page 39, Figure 4 gives this example of Nest-INE notation with extra clues to assist in comprehension in nested conditionals.

    if high:
        if wide:
            if deep: weep
            not deep:
                if tall: weep
                not tall: cluck
                end tall
            end deep
        not wide:
            if long:
                if thick: gasp
                if not thick: roar
                end thick
            not long:
                if thick: sigh
                not thick: gasp
                end thick
            end long
        end wide
    not high:
        if tall: burp
        not tall: hiccup
        end tall
    end high

This suggests the benefit of locally restating the conditions under which a statement applies.  An Amalog translation might be:

    weep
        high
        wide
        deep
    weep
        high
        wide
        not deep
        tall
    cluck
        high
        wide
        not deep
        not tall
    gasp
        high
        not wide
        long
        thick
    roar
        high
        not wide
        long
        not thick
    sigh
        high
        not wide
        not long
        thick
    gasp
        high
        not wide
        not long
        not thick
    burp
        not high
        not tall
    hiccup
        not high
        not tall

and this organization instantly makes it apparent that weep/0 and gasp/0 can be simplified.  In this example, Amalog might benefit from being able to put conjunctions on a single line.  The author continues with Figure 5 by effectively doing this exact same translation implying that it's an improvement over the traditional, nested conditionals.

"Text is essentially graphics with a very limited vocabulary."

### Scope marking in computer conditionals

Sime, Green and Guest; "Scope marking in computer conditionals—a psychological evaluation"; International Journal of Man-Machine Studies; 1977.

The authors compare Algol-style ("begin ... end") scope markers with markers that carry "redundant information about the conditional tested".  The latter gives excellent performance compared to the former, especially during debugging.  This is an argument for Prolog clauses that completely state their conditions.

Authors note that it's also important for sequence information to be available.  Prolog clauses encode sequence quite clearly through conjunction.  Predicates encode it clealy through vertical layout of clauses.

The entire article isn't avaialable online, but from the abstract it seems like Prolog balances both goals at once.

### How spacing impacts comprehension

There have been many studies on the impact that spacing and typography have on reading comprehension.  Search for "square span" or "spaced unit" typography for examples.  The results are mixed and at best show mild improvement in comprehension.

These results aren't directly applicable to whitespace sensitive programming syntax, but it does suggest that comprehension impacts are minor or nil.

### Knowledge Organization ... in Computer Programmers

McKeithen, Reitman, Rueter, Hirtle; "Knowledge Organization and Skill Differences in Computer Programmers"; Cognitive Psychology; 1981.

Experts can process large amounts of information because they have acquired a superior organization of that information.  That organization is quite similar among experts and less so among novices.

I don't see many useful applications of this knowledge to programming language design.

### Natural Programming

Pane, Ratanamahatana, Myers; "Studying the Language and Structure in Non-Programmers’ Solutions to Programming Problems"

Summing a list of numbers in C requires: three kinds of parens, three kinds of assignment and five lines of code.  The same operation in a spreadsheet requires one line and one operator (sum).  This is a good example how high level operations are much simpler to work with than low level operations.

"looping control structures provided by modern languages do not match the natural strategies that most people bring to the programming task"

The programming style used among non-programmers is:

  * 54% - event-based ("when foo happens, bar happens")
  * 18% - constraints ("foo cannot happen")
  * 16% - declarations ("foo is red")
  * 12% - imperative ("do foo. do bar")

The dominant style in industry (imperative) is the single least natural technique seen in experiments.  Similarly only 5% used looping constructs; the remaining 95% performed operations on entire sets.  This suggests a functional mindset.

Complex conditions were most often (37%) expressed as a mutually exclusive set of rules (just like Prolog clauses).  However, 27% expressed them as a general case with exceptions (they typically, 92%, use the word "but" to denote it).  I don't know of any programming languages that offer this construct, but it seems obviously convenient.  I was surprised that 23% used complex boolean expressions.

When "modifying state" (their term), 61% treated the state as an attribute of the entity.  This sort of has an object oriented flavor without the nasty connotations of inheritance.

Most people use "and", "or" to mean boolean operations.  "then" is used for sequencing.

When performing iteration, people typically (73%) only state the exit condition.In that sense, the looping is implicit.

For both "remembering state" and "tracking progress", variables are unpopular (only 11% and 14%, respectively).  People seem to track state implicitly.

Mathematical operations are treated as mutable state 99% of the time ("add 100 points to the score"), although some people don't specify the variable or the amount precisely.  This is an area of natural programming that Prolog does poorly.  It makes me wonder if there should be macros for local, mutable variables which expand into static single assignment form.

Reading through this study, it struck me how often people used pronouns in their solutions.  They also used what I'll call implicit argument passing.  Namely, when an action was performed, they didn't specify which values of the current context the action was performed on.  As a human reader, it was obvious which arguments were intended.  Why couldn't a compiler make these same deductions and only complain when it can't determine a unique solution?  For example,

    PacMan moves forward, hits a wall, then stops.

which might be translated as

    movement PacMan
        move_forward
        hit_wall
        stop

so each predicate demands an argument.  There is only one value in context, so that must be the argument intended.  It's only ambiguous if `move_forward/0` exists.  This also reminds me that programming languages almost always through out all information contained in variable names.  Why not use variable names to determine which predicates should receive that variable as an argument.  That probably requires someone to describe variable names or naming conventions.

In 100% of cases, the not operator has low precedence.  "not a or b" means "not (a or b)".  Subsequent studies (see Tabular below), show that "not" has higher precedence than "and" but lower precedence than "or".

People seem to use sets as a primitive data structure even though they don't know about data structures.  Few languages have convenient support for sets.


[Tabular and Textual Methods for Selecting Objects from a Group](https://www.cs.cmu.edu/~pane/VL2000.html)

People have problems with the words "and" and "or" confusing which means what.  Perhaps this suggests that it's better to use punctuation like , and ; as Prolog does.

[Natural Programming Project](https://www.cs.cmu.edu/~NatProg/)
