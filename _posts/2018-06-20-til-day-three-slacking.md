---
title: Day Three--Slacking
tags: [ til, infra, intern, make ]
category: Work, Code
---

I promise it is work related!

## Today I Learned

1. I need a Thunderbolt-to-Ethernet adapter
2. Makefile syntax can be *hard*
3. Repeat: Communication is essential

For the Ethernet problem, it was a matter of needing one at work and not having
one. I figure that is the sort of thing I just have on-hand.

`make` spits out a lot of errors. And it's really frustrating, because sometimes
those errors don't make any sense. But it's fine. Everything is fine.
Effectively, I was helping a co-intern work on a Makefile, and we wanted to do
something like this:

```make
deploy:
	@if ! some_cmd --params ; then
		some_cmd
	fi
```

Only, that doesn't work. I have yet to go back and read the make documentation
(it's on my to do list, don't worry), but trial and error with a simplified
version showed that this works:

```make
deploy:
	@if true ; then \
		echo "Hello world" ; \
	fi
```

Now, in normal shell syntax, you don't need the semicolon on the echo line, and
you don't need those line continuations. So you can imagine why I'm
perturbed--the above is *ugly*.

Oh, and by the way, I finally got into the company Slack. Still no email access,
but at least I can communicate and Get Stuff Done™.
