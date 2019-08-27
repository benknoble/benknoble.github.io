---
title: The Alignment Axes of Type Systems
tags: []
category: Blog
---

| | Lawful (static) | Neutral (none) | Chaotic (dynamic) |
|-|-----------------|----------------|-------------------|
| Good (strong) | C, Java, the ML family: every object has a type, and it must be correct at compile time | | Perl6, (Lisp I think), Python: every object has a type, but variables don't have static compile-time types. All the checking happens at runtime. |
| Neutral (none) | | No types! | |
| Bad (weak) | ???: Things have types, but they are flexible (e.g., strings converted to booleans or arrays converted to hashes). The compiler guarantees, however, that all the possible conversions are still valid. | | Javascript: No types given, but they exist. Lots of runtime errors when things don't match. |

Summary:

| Type | Definition |
|------|------------|
| Strongly typed | Operations strictly require conforming types |
| Weakly typed | Operations may coerce (or cast) types from one to another |
| Statically typed | Types are checked by the compiler |
| Dynamically typed | Types are checked by the runtime |
