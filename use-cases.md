# Use Cases

Any programming language should be able to comfortably and cleanly (subjective criteria) accommodate the following uses cases.  These are use cases that occur frequently in "real world" software development.

Each use case should be described in high level terms that don't favor one implementation over another. Each language may choose a different, clean way to accomplish the goal.

Implementations of these uses cases should be included in the standard library.

## Serialization

Serialization describes the relationship between a language's internal data format and a sequence of bytes in some public format.  Popular public formats include JSON, MessagePack, BEncode, Protocol Buffers, etc.

Not all serialization formats are general purpose.  For example:

  * HTTP messages
  * Go gob
  * Perl storable
  * Python pickle

## Encoding

Encoding describes the relationship between a pure byte sequence and a specialized byte sequence.  Specialized formats include base64, URI encoding, base32, etc.

## HTTP client and server

HTTP has become the Internet's lingua franca protocol.  It should be comfortable to create both clients and servers.

## Data structures

Arrays, maps and sets are three of the most widely use data structures.  It should be comfortable to define those data structures and the standard library should have exception support for them.  This includes different APIs or representations of those data structures for different circumstances.
