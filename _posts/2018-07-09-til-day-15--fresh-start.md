---
title: Day 15—Fresh Start
tags: [ til, infra, intern, builds, python, json, git, make, shell, tdd ]
category: Blog
---

Refreshing your browser page does not count as one.

## Today I Learned

1. Builds turn green eventually
2. How to use more tools
3. Reading never stops

## Greenie

> That's an old-time word for 'noob', youngster.

The task I've been working on for the last two weeks got an official "green
build" today. I had some last changes I wanted to test, so I kicked that off
when I went home.

When I walk in tomorrow, I should know whether or not I can merge.

Those changes are actually present earlier in the `git` history, but I reverted
them to ease testing when I thought they might have been part of the culprit.
Now that I know things work, I can put them back in. They constitute
backgrounding two build steps so that they run in parallel rather than
series--I'm hoping to get a speed increase out of this.

On a further note, I read an interesting [post][] in response to an [article][]
about TDD and its wastefulness. ~~I'll link them back later if I can find them
(it was on a different machine).~~

One point mentioned was that these kinds of tests condition developers to assume
"green is good," meaning my code is perfect and didn't break anything.

Well, firstly, these aren't unit tests, they're actually integration and
regression tests, but we'll ignore that. I *did* get a little ego boost when I
saw that green light--and now it's worrying. Did I really do everything right?

Fortunately, most of my changes were (small) shell-script refactorings. They had
to [preserve all side-effects][preserve] (much like compiler optimizations), so
as long as the end result is the same things should be fine. In fact, I hardly
changed the "real" code; I mostly split off functions and used data structures
and bash-isms where appropriate to write code with clearer *intent*.

I *also* have this habit when I'm working on shell code of writing little
throwaway scripts (usually named `some.sh`) that I can run harmlessly. I've used
this technique with fake `Makefile`s before as well. Effectively, it lets me
test code structures or external tooling to make sure the results are what I
expect, or fix it if they're not.

So, I'm *fairly* confident about the correctness--"fairly" as in "justly."

## Tooling Around

I also spent a chunk of time playing with python and json. I learned some quirks
about both of their syntaxes today. They will be of great benefit as I continue
to design and implement my change-and-make-based artifact-caching system (code
name: cake).

I still have to investigate how `__future__` imports affect code in a module,
and code in modules importing that module.

## Books Books Books, Words Words Words

Lastly, it is always important to acknowledge that the life of a software
developer, engineer, or writer (after your preference) is highly tied to reading
documentation and self-educating.

Today, this meant more posts about git internals, python, and vim. If my tools
aren't sharp, then I can't cut anything with them.

But if *I'm* not sharp, how do I know what to cut?

[preserve]: {% link _posts/2018-06-22-til-reading-refactoring-and-rpatterns.md %}#functional-refactoring
[post]: https://dmerej.info/blog/post/my-thoughts-on-why-most-unit-testing-is-waste/
[article]: http://rbcs-us.com/documents/Why-Most-Unit-Testing-is-Waste.pdf
