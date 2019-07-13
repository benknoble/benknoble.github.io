---
title: ':tada: Announcing the release of tmplr! :tada:'
tags: [ 'github', 'python', 'pip', 'templates', 'shell' ]
category: Release
---

I am pleased to announce the release of version 0.1.0 of [tmplr][tmplr]! You can
find its online documentation at [pip][pip].

## What is it?

`tmplr` aims to be the holiest CLI templating system that is easy to write and
use.

It provides

- `tmplr`: render a template into a file and edit it
- `temples`: manage your temples (templates)

## Why is this needed?

I write lots of similar files (vim ftplugins, tmux scripts, blog posts, etc.)
which follow nearly standard formats.

I then would frequently put together a script with a template to generate the
new one when I wanted it. This got boring and repetitive. So I automated.

## How?

We mostly lean on `string.Template` from the python3 standard library. After
that, it's a little string and path manipulation, things python excels at.

## Future?

Not much, unless there are substantial bugs or feature requests. It seems
relatively stable, and I'll be using it nearly every day.

## How can I help?

Use the code! Read it, help improve the documentation, report bugs, etc.

Dive in to our issue tracker, and see if there's something you can help with.

Write more tests (we'll never have perfect coverage).

[tmplr]: {{ site.data.people.benknoble.tmplr }}
[pip]: https://pypi.org/project/tmplr/
