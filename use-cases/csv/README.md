# Background

The file `munge.pl` processes a CSV file from Lending Club's secondary market.  It generates a new CSV file that can be used for factor analysis in R.

# Amalog Features

This section expounds on Amalog features seen in the example.

## handle

Makes a predicate (`err` in this case) the active condition handler for the current lexical scope.  If code executed in this dynamic scope signals a condition, `err` gets a chance to respond.

## pipe

Like a DCG.  It creates a pipeline of predicates.

The first predicate is called with a single, extra argument.  The predicate should bind its output to this argument.

If the final predicate is a variable (like `PastDue`), the pipeline's output is bound to that variable.  Otherwise (like `csv "secondary-munged.csv"`), the final predicate is called with a single argument containing the pipeline's output.

All other predicates are called with two extra arguments: the input from the previous stage and the output for the next stage.

The `csv` predicate knows it's generating rows from a file if its second argument is unbound.  It knows it's printing rows to a file if its second argument is bound.

## arg

Like arg/3 in Prolog.  It relates a named property, a term and that property's value.

## rx

A macro that compiles a regular expression into some internal representation so that it can be matched against inputs (or used to generate matching outputs).

## .

Functional sugar for accessing a term's named property.  For example,

```amalog
say Foo.bar
```

is sugar for

```amalog
arg bar Foo X
say X
```

## math

A macro that expands mathematical notation into Amalog goals.  For example,

```amalog
say (math `1 + 2 + 3`)
```

is sugar for

```amalog
plus 1 2 X
plus X 3 Y
say Y
```
