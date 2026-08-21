---
title: Theory Building with Git
tags: [ software-engineering, git ]
category: [ Blog ]
---

A few notes from thinking about [Feeling of Coding's episode on "Programming as
Theory Building"](https://feelingof.com/episodes/061/).

(Yes, I'm late listening to it. No time like the present!)

At some point in the episode, our hosts remark that Git is not well-designed for
theory building. I must disagree.

Admittedly, the theory building the episode discusses is particular; in Naur's
conception (as I understand it), only the original team working on the codebase
has the theory, and there is _no way_ to transmit it to anyone else. Any attempt
can only be an approximation and would lead to a new theory, not the original.

And yet… isn't Git a wonderful approximation? Git captures both historical
context and the evolution-in-time of the codebase. Arguably, that is likely to
omit a lot of external context and personal viewpoints of the original team. Yet
through commit messages we have the ability to share in writing a part of our
theory that isn't evident from the code itself.

A commit message will never capture or transmit the entire theory. Still, it's
value lies in making available more of the theory than we get with just code, or
just code + revisions.

Finally, I'd like to point out that Git was originally designed for Linux kernel
development. That kind of model has no analog in what I recall of Naur's paper:
the "team" is large, distributed in all dimensions, and no one person has a
complete theory of the entire kernel.

So if that disqualifies Git from serving Naur's original theory building, that's
fine with me. I think you'll find it hard to argue that Git is poorly suited for
transmitting theory about the kernel since it's used so successfully to
contribute to and explore the kernel's source.

While I'm here, I should also point you to [Computer Science Off Course
Epsiode 1](https://www.felienne.nl/csoc-s01-e01/), which covers the same paper
in interesting ways. This includes that generating code with LLMs leaves us
without a theory of the code, so we are left unable to justify decisions or
reason about modifications. Programming is not just the generation of code.
