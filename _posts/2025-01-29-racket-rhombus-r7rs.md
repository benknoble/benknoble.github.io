---
title: 'Collected chats about Racket'
tags: [ racket ]
category: [ Blog ]
---

This post serves primarily to host an indexable copy of some chat replies about
the Racket programming language.

## Questions about [R7RS implicit phasing](https://codeberg.org/scheme/r7rs/issues/217)

- *a*: hm. what stops a `#lang` from reimplementing whatever algorithm a
  r7rs-large compiler does?

- *b*: in particular, nobody has yet worked out a way to maintain the Separate
  Compilation Guarantee™ when the compiler does phasing automatically

- *c*: You can certainly implement that (the same way that algol60 is
  implemented) but you would lose the kind of integration between r7rs
  modules/macros and racket modules/macros that eg the `#lang r6rs`
  implementation has

- *me*: Would you have to? I’m hand-waving and clearly a non-expert, but it
  seems like it should be possible (procedural macros!) to implement enough of
  the compiler and expander as a compile-time process of the lang, and then
  eventually expand into an equivalent Racket module with all the relevant
  annotations added.

    This doesn’t seem efficient (since it’s sort of like expanding the whole program
    twice, or worse possibly in some quadratic way), but IUIC typed racket has to do
    something similar in terms of duplicate expansions. Obviously the effort to
    implement this way would be higher (?).

- *c*: You might be able to do this especially for a single module, but it's not
  obvious if you could get the necessary information from other modules. It's
  possible you could build a lot of infrastructure to do it, but I'm not
  certain.
