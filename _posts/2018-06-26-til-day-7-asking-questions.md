---
title: Day 7, Asking Questions
tags: [ til, infra, intern, builds ]
category: Blog
---

Because that's what the job of any scientist is.

# Today I Learned

1. To ask the right questions
2. Stuff ain't perfect
3. I really shouldn't do multiple [tils][] in one night

## Right ¿?

The [massive][] [refactoring][] I've been doing is finally done, freeing me to
actually complete the important task.

I knew what the end goal was, but not what the specifics of achieving it were.
So I asked. I spent probably a half hour going back and forth with the colleague
who was my go-to point for the task, and he made sure I felt like knew what I
was doing. He even said one time:

> Good question…

But I learned that some questions were better than others based on the answers
and my difficulty asking them.

The lesson is to think about your questions (and the answers you want). It will
help you.

## Perfection

Our infra builds run on [Jenkins][]. This is great for automated testing.

But the Jenkins is all configured through a web-interface. It has a travis-like
repo-level yaml configuration system. It can do the *whole* thing in a
version-controlled format.

So what do we do? Make it impossible to version control or edit reasonably.

Actually, its a work in progress, and there are unfortunate historical reasons
to keep things the way they are. But it's still frustrating. To edit the
configuration on the repo I'm changing, which is necessary, I had to dissect an
ugly build script. Yes, another one. Because it wasn't as simple as `make` or
`./build`.

The new one will use my refactored version, stored in the repo, if it exists.
This will make editing the configuration in the future part of the repo, with
all the `git` benefits that brings.

But, to preserve backwards compat, the build step will fall back to the original
code, stored on the online interface. :eyes:

I mean, I get it, but all it takes is one bad egg (or one keyboard swipe) to
delete all of that. Do we have a recovery plan? Who knows.

## Multiple [tils][]

A complete bust. I had to do yesterday's today, along with this one. Never
again.

[tils]: {% link pages/tags.html %}#til
[massive]: {% link _posts/2018-06-22-til-reading-refactoring-and-rpatterns.md %}
[refactoring]: {% link _posts/2018-06-25-til-week-2--refactoring.md %}
[Jenkins]: https://jenkins.io
