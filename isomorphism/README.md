# Spec

A given program has only a single serialization as a byte stream.  A valid byte stream serialization has only a single in-memory representation.  In other words, programs are written in a canonical form.  Deviations from this canonical form are a syntax error.

Syntax errors:

  * presence of tab characters
  * presence of trailing whitespace
  * presence of carriage return characters
  * missing a version number
  * using a non-UTF8 encoding

Outlawed characters are allowed within raw character strings.


# Examples

These two values are semantically identical.  However, only the first is in canonical form so it’s the only valid one.

    foo bar baz 2+3
    foo(bar baz +(2 3))

It’s expected that lenient tools will convert from the latter to the former.  This could be a helpful guide for those just learning the canonical syntax.

Lenient tools are also helpful during development.  I programmer doesn't have to fret about canonical syntax.  He types something that's roughly correct and his editor automatically converts it to canonical syntax when he saves.  The GoSublime package (for Sublime Text editor) does this.  It's a pleasure to work with.  I type out huge swaths of ugly code and it instantly reformats them nicely and cleanly.


# Reasoning

Writing programs in a canonical form eliminates bickering/policies/rewrites caused by unimportant layout details.  It allows SCM tools to perform diffs on the underlying data structure without tripping over semantically irrelevant layout details.  Tools can generate code (refactoring editors, etc) and have it automatically match the surrounding code style.  Primitive  analysis tools can pattern match the canonical syntax without having to cover hundreds of equivalent variants or write a full parser.

Most languages have pretty printers which reformat source code to comply with best practices.  Go takes this somewhat further by mandating specific layout on if-else blocks.  It works quite well in practice.  It also provides a lenient tool (`go fmt`) for converting from lazy to strict syntax.  OS X's AppleScript editor automatically converts lazy syntax into strict syntax when saving (changes layout, changes field names, etc).

By giving syntax errors for all deviations from canonical form, we reserve huge swaths of syntax for future expansion.  If the compiler leniently allowed syntax variations, developers would squat on that syntax (by using it in their code).  Then we’d lose it for productive future expansion.


# Use Cases

Static analysis tools, refactoring tools, source code management tools.  Future syntax expansion.
