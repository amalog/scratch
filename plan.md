# Implementation Plan

Implementations in at least three different languages during early development. This should help me spot implementation and spec issues early. It will also help me to create a good, automated test suite that future implementations can use. Tentative language choices:

  * JavaScript (imperative, dynamic)
  * Haskell (functional, static)
  * Prolog (logic, dynamic)

Start JavaScript by writing a CodeMirror mode.  This gives us a tokenizer, text editor, syntax highlighter and auto-indenter for free.  This will also help me recognize complexity and rapidly iterate on syntax and tooling.
