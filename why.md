# Why Amalog?

The world has many programming languages.  Why create another one?  This document provides high level goals to answer that question.  Detailed answers will be created elsewhere.

## More Declarative

I want a logic programming language that's more declarative than Prolog.  I've written too many clauses which vary only in goal order or had to use [library(delay)](http://www.swi-prolog.org/pack/list?p=delay).

## Small Interpreter

One should be able to write an Amalog interpreter without much trouble.  This encourages experimentation and hosting in various platforms/languages.

## Compiles to Other Languages

I want a logic programming language which compiles into other languages.  If I'm writing a JavaScript or Go project, I want to be able to generate libraries in those languages directly from my Amalog source code.

## Amenable to Static Analysis

Static analysis (of which type systems are one flavor) can be useful tools for improving productivity and software quality.

## Amenable to Partial Evaluation

Partial evaluation of logic programming languages has great potential for improving their performance and compiling high level source into low level code.

## Simpler Syntax

I want a logic programming language whose syntax can be parsed with only a little code.

## Canonical Syntax Style

I want a language with canonical layout. There should be no arguments over how a program's code is formatted.  It can't be part of an external tool or people forget to use it.
