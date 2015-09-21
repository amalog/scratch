# Spreadsheets as Programming

Spreadsheets are one of the most powerful programming tools available for
quickly converting an idea into a usable tool.  Although they're not right for
every occasion, their strengths could teach language designers some valuable
lessons.

# Example

I have a small spreadsheet which calculates how Bitcoin assets should be divided
among each partner in a partnership.  That spreadsheet offered a concrete which
catalyzed some of the following ideas.

## Translation into code

My first attempt was to translate the spreadsheet from its current visual style
into a style that's similar to existing, text-based programming languages.  Each
variable represents a spreadsheet cell.  The goal was a literal translation, not
a nice language.

```
mmjt_partner_count = 2

marc_fixed_share = 5_000
    format: $x,xxx.xx
    note: "As agreed upon in the contract dated 1 May 2013"

qt_wallet_balance = 23.14
    format: xxx.xx BTC

bitfinex_wallet_balance = 4.111
    format: xxx.xx BTC

multibit_wallet_balance = 9.89735
    format: xxx.xx BTC

mmjt_wallet_balance = 25.37
    format: xxx.xx BTC

personal_wallet_balance = sum(
            qt_wallet_balance,
            bitfinex_wallet_balance,
            multibit_wallet_balance,
        )
    format: xxx.xx BTC


personal_wallet_usd = exchange_rate * personal_wallet_balance
    format: $x,xxx.xx

exchange_rate = GOOGLEFINANCE("BTCUSD")
    format: $x,xxx.xx

mmjt_wallet_usd = mmjt_wallet_balance * exchange_rate
    format: $x,xxx.xx

mmjt_shareable_usd = mmjt_wallet_usd - marc_fixed_share
    format: $x,xxx.xx

mmjt_partner_share = mmjt_shareable_usd / mmjt_partner_count
    format: $x,xxx.xx

michael_btc_worth = personal_wallet_usd + mmjt_partner_share
```

### Syntactic observations

The translated code above is not designed to be pretty but it does highlight
some syntactic aspects which a spreadsheet does well:

  * formatting code is verbose. spreadsheets hide that away
    by making it implicit in a cell's output. one drills down when interested
    in modifying or learning formatting details

  * formatting code is repetitive. a spreadsheet addresses this by allowing
    one to copy-paste a format from one cell to another but that still causes
    repetitive work if a certain kind of formatting needs to change

  * there's a high correlation between variable names and desired formatting.
    this reminds me of how CSS allows formatting to be factored out to a
    separate, central location. one might imagine a CSS rule like
    `.wallet.balance { format: xxx.xx BTC }` which could replace 4 lines
    in the above code

  * multiple types of metadata per variable (ex, `format` and `note`).
    programming languages usually only allow one (a type) or force the
    metadata to be associated with the variable's current value, not the
    variable itself.  attributed variables in Prolog are a counter example.

  * the code shows a repetitive formula pattern relating the value of
    `foo_wallet_balance` to `foo_wallet_usd` (multiplying by `exchange_rate`).
    a spreadsheet factors out that rule by dragging a formula across adjacent
    cells which implicitly performs the calculation.  a programming language
    factors it out by creating a subroutine which one calls explicitly.
    it might be interesting to have a rule like
    `XXX_wallet_balance * exchange_rate <=> XXX_wallet_usd` which
    instantly creates a "wallet USD" variable for every "wallet balance"
    variable and vice versa

## Spreadsheets do well

This section describes some things that spreadsheets do does better than
traditional code.

### Implicit names

[Naming things](http://martinfowler.com/bliki/TwoHardThings.html) is one of two
hard problems in computer science.  Spreadsheets dodge this problem by assigning
implicit names to all variables ("cells") based on geography.  Spreadsheets
provide named ranges and named cells for the times when one needs added clarity
but doesn't force users to create a name for everything.

The closest analogy in programming is the
[pointfree style](https://wiki.haskell.org/Pointfree).

### Formatting

Formatting preferences are attached to each individual variable.  They're not
attached to a type.  With Prolog's `portray/1` or Haskell's `show` you must come
up with a distinct type if you want distinct formatting.  Or you can add some
extra formatting code and call it explicitly.  Both techniques seem more
heavyweight than the way spreadsheets let me click and say "format this thing in
this way".

### Automatic output and layout

A spreadsheet comes with fully workable defaults for layout (how code is
arranged) and output (how values are displayed). Programming languages usually
require manual layout (less so with tools like "go fmt") and manual output code.

In a spreadsheet, I can write `=3+3` and instantly see the value `6`.  In nearly
all programming languages, I have to write `print(3+3)` as if it were highly
useful to calculate a value and do nothing with it.  Spreadsheets adopt a more
sensible default: output values unless told otherwise.

### Drag and drop variable renaming

When I drag a cell to a new location, I change its geography.  That changes its
name which instantly rewrites all formulas that use the variable.  A few
programming tools support variable renaming but it rarely feels this easy.

### Draggable macros

Every formula is actually a macro definition.  Copying and pasting a formula
applies that macro to a given context to create a new formula.  That new formula
is, in turn, a new macro.  Macro expansions are based on geography.

Macros sort of serve the function of user-defined functions since spreadsheets
don't have those.  However it feels like there's a powerful idea here: making
easily debuggable macros more readily accessible.  In most programming
languages, macros are reserved for power users.

### Instant feedback

A spreadsheet provides instant feedback after every code edit.  This facilitates
experimentation and learning about the code.  Programming environments that do
this are relatively rare.  Witness the massive adoration for
the live programming demos in
[Bret Victor's "Inventing on Principle" talk](https://vimeo.com/36579366).
Had that sort of thing been commonplace, it wouldn't have raised such interest.

### Execution Order

A spreadsheet automatically calculates the order in which to apply each formula
based on its data dependencies.  In traditional languages, programmers spend
substantial effort determining the order of operations.  By taking care of this
details, spreadsheets remove one more concern from the programmer's cognitive
load.

## Code does well

This section describes some things that traditional code does better than
spreadsheets.

### User defined functions

Programming languages support user-defined functions natively.  Most modern
spreadsheet applications recognize this failing and have some mechanism for
creating functions.  However, they don't seem native.  They feel like a
traditional programming language bolted on to the spreadsheet paradigm.

### Loops and recursion

Programming languages support loops or recursion.  Trying to emulate these
in a spreadsheet becomes very difficult because one must allocate enough spare
cells and copy enough formulas to unroll the loop.

I've created many spreadsheets where I wished I had access to a native loop
construct.

### Compound data types

Programming languages support compound data types like structs, lists, maps,
etc. I'm not aware of anything similar in spreadsheets. Values can only be
atomic (numbers, strings, dates, etc.)
