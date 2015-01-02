# Dev and Prod Modes

Software development naturally falls into two modes: development and production.  Development mode is rapid, exploratory and [flow](http://en.wikipedia.org/wiki/Flow_(psychology))-heavy.  Production mode is slow, deliberate and concerned with details.  Software tools should recognize and cater to the mode in which a developer is operating.

## Dev Mode

Dev mode should be forgiving and respond as rapidly to input as possible.  It should provide information about the running system and allow the developer to iterate on it in near real time.  Mistakes and hand waving should be tolerated as much as possible.

## Prod Mode

Prod mode should be relentlessly strict.  Any small mistake should be brought to the developer's attention.  The compiler should draw attention to code which seems likely to cause problems later.  This mode is the proper place for most static analysis such as type systems, mode analysis, complexity analysis, etc.


## Communicating the Mode

Real development is a spectrum between dev and prod modes.  In that sense, a "--dev-mode" or "--prod-mode" compiler switch seems artificial.  Although maybe it's good enough to accomplish the goal.

Which mode should be the default?
