Allow integers with embedded underscores to separate each thousands segment. Allow integers, decimals, hex and code point (like Prolog `0'z`) notations. Omit octal, binary, other bases and scientific notation.  Scientific notation can be implemented as an `e/2` infix operator which expands `e(23 9)` into `23*10^9`.

It might be useful to have something like [Kawa quantities](https://www.gnu.org/software/kawa/Quantities.html).  They allow one to write numbers along with their associated units.  For example to represent 3 meters, one writes `3m` which becomes `m 3`.  A more complicated example to represent gravity on Earth: `32.174ft/s^2` which becomes `/ ft(32.174) ^(s 2)`.

