---
title: ':tada: Announcing the release of plink! :tada:'
tags: [ dotfiles, make, perl, shell, DSL, design, posix ]
category: Release
---

I am pleased to announce the release of version 1.0.0 of [plink][plink]! You can
find its online documentation on [GitHub][plink]. (I [did the thing][rant] this
weekend!)

## What is it?

`plink` provides a drop-in replacement for managing dotfiles via `make(1)`, and
it does so with a DSL designed for symlinks.

## Why is this needed?

Managing symlinks with make is nice, but prone to error, particularly if you
stick to POSIX. This solves that problem.

## How?

Perl, baby, Perl.

## No, how do I use it?

Clone [plink][] as a submodule of your dotfiles, `mv Makefile dotfiles.plink`,
and put this shebang at the beginning:

```
#! /usr/bin/env plink_submodule/Plink.pm
```

Run the file (`chmod u+x dotfiles.plink`), and then use make as usual! `env` can
be replaced with `perl` if you don't have it.

You can then start to take of plink syntax, all documented in the module and on
GitHub.

Also see [vim-plink][] for vim syntax files!

## How can I help?

Use the code! Read it, help improve the documentation, report bugs, etc.

Dive in to our issue tracker, and see if there's something you can help with.

Write more tests (we'll never have perfect coverage).

[plink]: {{ site.data.people.benknoble.plink }}
[vim-plink]: {{ site.data.people.benknoble.vim-plink }}
[rant]: {% link _posts/2019-07-12-plink-rant.md %}
