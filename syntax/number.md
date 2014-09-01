Allow integers with embedded underscores to separate each thousands segment. Only support decimal integers natively.  Hex, octal, binary, codepoint are rarely used and should be supported in a library (by macro expansion to decimal integers). Scientific notation can also be implemented as a library.  For example,

```
N = num `0xbeef`
N = num `0b1101`
N = num `2.7e14`
```

It might be useful to have something like [Kawa quantities](https://www.gnu.org/software/kawa/Quantities.html).  They allow one to write numbers along with their associated units.  For example to represent 3 meters, one writes `3m` which becomes `m 3`.  A more complicated example to represent gravity on Earth: `32.174ft/s^2` which becomes `/ ft(32.174) ^(s 2)`.  Also consider [F# units of measure](http://stackoverflow.com/questions/40845/how-do-f-units-of-measure-work/81467#81467) and [Frink units](http://futureboy.us/frinkdocs/#SampleCalculations) as prior art.
