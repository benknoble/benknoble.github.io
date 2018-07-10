---
title: Day 11--Third Time's (Not) Always the Charm
tags: [ til, infra, intern, builds ]
category: Work
---

:shamrock: :shamrock: :shamrock:

Ok, ok, I'm not done with the emoticons yet.

Also, since tomorrow is the 4th of July :fireworks: and I don't have work :grin:
I'm not doing a TIL. Instead you'll get the [feature][] that spawned out of
yesterday's TIL.

## Today I Learned

1. Caching is hard
2. Regressions are hard

## Cache ! :baseball:

I'll get to why I had time to work on this in a moment (and it'll wind up being
related to tomorrow's [feature][] article as well), so hang tight.

In the meantime, let me tell you about [another][] [strategy][] for [build][]
[time][] [improvement][]: cached artifacts.

It goes like this. We have a build--call it `meta`--that requires a lot of
smaller components, each of which have their own build process. So, to build
`meta`, we build every single component. Every. Single. Time.

This isn't such an issue when most of the components take 0-20 seconds. But a
few take several minutes, and some even break the 10 minute mark. So the overall
time is quite long.

### Solution: Don't Do That

Rather than build these components every time, it would be great if we could
determine which ones needed to be built (because their source code was changed),
and which ones could be pulled in from a cache.

Step 1 is easy: `git-diff` actually has a `--names-only` option that has it spit
out the names of files that were changed, so we can compare between commits and
determine what source code was touched. Then, using a map of patterns (that
match pathnames) to build components, we know what has to be built from scratch.

Step 2 is more involved. Well, computing the list of components to get from the
cache is easy (it's just the set of components minus the set of components to
rebuild). But designing the cache is slightly harder.

Rather than reproduce my whole thought process, I'm going to put my proposal
spec [here][spec]. Note that `/usr/global/` is a shared file-system, and we're
having internal discussions about using docker volumes on the local build
machines, giving each machine it's own cache. I don't know how to do some of
this stuff with docker, as I've never used it in this capacity before, but we'll
see what decisions end up made.

## Regress Express

Our regression suite (called Express, or maybe using a tool called Express, I
really don't know) has suffered several issues over the past few workdays.

Some were infrastructure issues, others weren't, but effectively I've been on
and off trying to get the suite to run so I can verify my code. In the meantime,
I've been doing things like this cache and the DHCP documents.

So, yeah, apparently that stuff is hard to get right. Though, having seen some
of the code, I'm not surprised.

[another]: {% link _posts/2018-06-22-til-reading-refactoring-and-rpatterns.md %}
[strategy]: {% link _posts/2018-06-25-til-week-2--refactoring.md %}
[build]: {% link _posts/2018-06-26-til-day-7-asking-questions.md %}
[time]: {% link _posts/2018-06-27-til-day-8-context-and-computers.md %}
[improvement]: {% link _posts/2018-06-28-til-day-match-0-9--regex.md %}
[spec]: https://docs.google.com/document/d/14HxZFLA7eMN6leZeBBRfWUUuBFE5t3vyfIDwgfm5O3I/edit?usp=sharing
[feature]: {% link _posts/2018-07-04-feature-cycles.md %}
