---
title: Day 16--The Three Pieces of Software
tags: [ til, infra, intern ]
category: Work
---

There's probably more than that, but these are the bigguns.

## Today I Learned

1. Communication breaks down
2. Design is more than half the battle (and fresh eyes never hurt)
3. 1+1 ain't always 2

## Communication

How many times have you heard me say it? *Communication is key.* And sure, that
makes a nice, easy sort of sense--too easy, I say. Too easy, because it's apt to
be forgot.

Today I was witness to the result of a communication breakdown. It wasn't
exactly pretty, but it got the point across: some things aren't working, and we
need to fix them. That's all I'll say about it.

Piece #1: Communication (horizontal, vertical, and circular--if you achieve
extra-dimensional, please let me know).

## Architects

Ever built a home? No? Ever *thought* about it? Well, I know this because my dad
used to build 'em, but homes actually have these things called *plans*. You
know, these magical documents that lay out how, in a perfect world, this is
exactly the end result.

Well, it turns out good plans have been designed. And, like good software, this
step is important.

Much like you don't want your toilet to be right smack next to your kitchen
island, you want to think about how you're going to code up a fancy new feature.
And I mean really put some brainpower into it; this isn't write it down once and
then do it.

So, today, I spent a good couple hours working, on a team and alone, on the
design for the new cache system. You'll be happy to know it's significantly more
explicit, formal, and robust. And that is only possible because of (1)
communication, and (2):

Piece #2: Good Design.

## 1+1 ≠ 2, or, Math is Broken, and I Need to Fix It

Ok, well, *math* isn't broken, per se. But a build that runs fine sequentially
is.

Think of it like this. There are two steps to the build. Step 1 gives us `1`.
And Step 2 gives us `1`. But they don't depend on each other--I can actually do
them in any old order I want to (and I've checked that out pretty thoroughly).

So, the end result is clear `1+1=2` right?

Well, here's the tricky part of the beast: when I run them __at the exact same
time__, all hell breaks loose. Now I get things like `NaN`, `∞`, and all manner
of other nonsense.

(Yes, this is directly related to the building and refactoring I've been writing
about for a number of posts. I'm so close I can taste it. Parallel stuff is
hard.)

So, Piece #3: Fixing stuff when it's broke.
