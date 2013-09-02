Amalog should stipulate how command-line implementations should handle arguments.  Most Prolog implementations differ in their command line arguments, so one must write a wrapper script to present a consistent front-end across them all.  This makes it needlessly complicated to switch between implementations.

The command line spec should require that passing a file name to an Amalog implementation runs that file as a script.  This is necessary to support portable shebang lines across Linux variants.
