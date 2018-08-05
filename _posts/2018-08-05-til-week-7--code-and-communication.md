---
title: Week 7--Code and Communication
tags: [ til, infra, intern ]
category: Work
---

One week after my forays of unit testing, and I'm almost ready to ship.

_I got caught up in a busy week, full of surprises and late nights. So I'm
snowballing it all together._

## This Week I Learned

1. How it feels when a plan comes together
2. How to build programs with `git`-like subcommands using `argparse`
3. Communication is essential

I also spent time in the lab racking, stacking, lacing, and labeling servers,
but it's harder to write about because the process depends so heavily on the
specific configuration desired. Suffice it to say Wednesday was a good,
physical day, a nice change of pace from my cubicle.

At any rate, on with this week's lessons.

### Wrapping It All Up

After weeks of development, I finally have a full library of code that passes
all my tests, implements all the desired "version one" features, and is nearly
ready to integrate. I am still working on the command-line interface, but the
project is coming to a close.

The students in raleigh have been offered time to present, demo, or whiteboard
anything they want from their summer. It could be a challenge, a project, or
something they learned. I will be presenting and demoing my caching project,
provided I finish it. And I'm very excited.

### CLI

Python, with a mature language ecosystem, has several libraries for building
command line programs. Click, docopt, and more all present themselves as easy to
use. But they aren't part of the standard library, and so they introduce
dependency.

Unfortunately, I am constrained--I can't have any dependencies (for the time
being). So I need a standard library solution--`argparse`.

Argparse is remarkably simple--I programmatically build up parsers by defining
what arguments they take and what to do with them. It takes care of building the
help messages, parsing the command line, and all that jazz. The most difficult
part was to decide how to implement subcommands.

Fortunately, `argparse` makes defining subparsers easy. They even recommend an
approach for associating a subparser with a particular method. With that
capability, I'm able to define the flags, positional parameters, and actions for
an entire CLI very quickly.

The idea is to use `setDefaults` on each subparser with a 'parameter' like
`func`. Then, when you parse the `args` out, you can call `args.func(args)`,
passing an object into whatever function is appropriate based on the subcommand
at the command line.

### Communication

It would seem, no matter how many times I repeat it, even I managed to forget
how important communication is.

A failure on my part to continuously update my colleague on the progress of this
caching project, in addition to some other changes in the way we tracked work,
lead to some concerns about how much time I was spending on which projects.

Happily, the concern was easily alleviated by the rapid progress I was making
(and my planned Tuesday finish). But it was a sharp reminder of how easily
things can slip away if I'm not conscientious of communicating with my
coworkers.
