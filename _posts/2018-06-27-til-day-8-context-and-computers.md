---
title: Day 8, Context and Computers
tags: [ til, infra, intern, shell, builds ]
category: Blog
---

I will keep this alliteration up until it kills me. Just sayin'.

# Today I Learned

1. Ubuntu downloads are hybrid ISOs
2. Context is king in shell scripting

## Does not compute

Remember how I [still][] didn't have my [work computer][]? I was able to put
Ubuntu on it this evening, and tomorrow should be using primarily it. Huzzah.

Let me tell you something about it though. The Ubuntu download is an ISO. No,
not like Tron: Legacy, it's an image file, a snapshot of an entire file system.
And everywhere online will tell you that, in order to make a bootable USB from
one, you need special software.

You don't.

At least, not anymore. Ubuntu decided to put out some kind of hybrid ISO, so you
can copy bit-by-bit to your USB and it will be bootable. I know; I did it.
There's a small bug that prevents macOS Disk Utility from working on it, which
is unfortunate, but `dd` does the job just fine. And you can use raw write mode
to speed things up.

## Context

Here's the thing about a lot of shell scripts. Many establish, much like a
makefile recipe, that the way to accomplish a task is a sequential set of steps.
A recipe. To foo the bar, we follow this list, frobbing along the way.

Now, we have some basic control flow: we can loop, doing the same step multiple
times; we can make decisions about which steps to do; and we can even have
someone else do a step for us in the background.

*Recipes are fine*, you're thinking (I can hear your thoughts)--*They work in
the kitchen*. Well, bub, my shell is not your kitchen. For one, my shell won't
taste bad if I leave it on too long. More importantly, if I screw up, I brick my
laptop and not my whole house. Which of those things is more important, I'm
still working on. The reason recipes require attention is __context__. In a
shell script, any one step could be affected by what's gone before. Current
directory matters, whether or not files exist matters, &c. This is not unlike
cooking, where having the dough mixed properly is essential to baking a cake.
But you can go back and fix the dough. A script can't do that on its own.

Here comes the tricky part--shell functions are a really nifty feature for
[refactoring][], enhancing the code's ability to read like English (or your
language of choice). They encapsulate components of the recipe, much like
`make_the_dough` might be a multi-step process necessary for `make_me_a_cake`.
But functions inherit their callers context. Current directory, environment
variables, &c. And this is a problem when we try to think of functions single,
isolated, perfect units.

In a perfect world, each function could be run entirely independently, and so
`cd` would never fail because we're not in the directory we thought we were
(thanks, caller function). This happened to me today and it borked my build.

Functions are not independent.

Unless you write pure functions, like `sed` and `grep` and other UNIX-style
filters that take input (or parameters) and output things. These transformations
are perfect. They are independent, and often idempotent. But eventually we need
I/O to Get Things Done™.

So, no, bash isn't purely functional (although we can do a good job building
reliable and composable units in it). Knowing this, we have to be defensive in
our functions. When we do something, we have no guarantees about our context,
and the burden is on us to handle that the right way. Sometimes, that means fail
spectacularly. Others, in the case of my `cd` problems, meant using absolute
paths so it couldn't fail unless things were really screwed up. But at the end
of the day, we have to recognize that things might not be the way we expect. How
do we react to that?

[still]: {% link _posts/2018-06-18-til-first-day.md %}
[work computer]: {% link _posts/2018-06-21-til-day-four-my-two-cents.md %}
[refactoring]: {% link _posts/2018-06-22-til-reading-refactoring-and-rpatterns.md %}
