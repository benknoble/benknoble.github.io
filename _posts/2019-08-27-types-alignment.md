---
title: The Alignment Axes of Type Systems
tags: [types, d&d-5e, prog-langs]
category: Blog
---

I map D&D alignments to type systems.

| | Lawful (static) | Neutral (none) | Chaotic (dynamic) |
|-|-----------------|----------------|-------------------|
| Good (strong) | C, Java, the ML/Haskell family: every object has a type, and it must be correct at compile time | | Lisp: every object has a type, but variables don't have static compile-time types. All the checking happens at runtime. The type cannot change or be implicitly coerced. |
| Neutral (none) | | No types! | |
| Evil (weak) | ???: Things have static (textual) types, but they are flexible (e.g., strings converted to booleans or arrays converted to hashes). The compiler guarantees, however, that all the possible conversions are still valid. | | Javascript, Python:  Types are flexible, due to implicit conversions. They are often not even checked at runtime, and operations fail then when not supported. |

Summary:

| Type | Definition |
|------|------------|
| Strongly typed | Operations strictly require conforming types |
| Weakly typed | Operations may coerce (or cast) types from one to another |
| Statically typed | Types are checked by the compiler |
| Dynamically typed | Types are checked by the runtime |

P.S. I've tried several times to classify Perl5 and Perl6 on this list (in v6,
everything is an object). The difficulty is that things are often either
scalars, arrays, hashes, or references to one of those; however, there is a lot
of implicit conversion. They might fit the Static/Weak (Lawful Evil) axis, but
I'm not sure: the compiler may or may not enforce the types of operations
(though the runtime does, in a way).
