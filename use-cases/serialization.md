# Serialization

Serialization describes the relationship between a language's internal data format and a sequence of bytes in some public format.  Popular public formats include JSON, MessagePack, BEncode, Protocol Buffers, etc.

Not all serialization formats are general purpose.  For example:

  * HTTP messages
  * Go gob
  * Perl storable
  * Python pickle
