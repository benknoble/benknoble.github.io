---
title: Week 5 (and a Quick Recap)
tags: [ til, infra, intern, builds, make, refactor, tdd, shell ]
category: Work, Code
---

I've officially crossed the halfway point of my internship. But don't worry,
because I start a co-op with the same company the week after.

## The Recap--My Kneecaps

Last week things got crazy, what with RPGs pushing their way into my writing/til
schedule.

Then, Friday, I drove home again for a martial arts event. For the curious, I
hold a 1st Dan in Tang Soo Do and was double-recertifying--I am now 3/4 of the
way to 2nd Dan. And my body is sore.

I had promised a feature by the end of the weekend. I didn't do it, so I'm
thinking I will spend this weeks feature on time management when I get to it.

In the meantime, enjoy a recap of the two things I learned at work on my half
day:

1. Bash can replace `sed` in a good number of instances
2. The parallel issues I was having had mostly to do with `./configure`

### I _Sed_ Take Out the Trash !

The most common usages of `sed` I see are pattern replacements. It's actually a
wonderfully built little tool, piggy-backing off the language of `ed` (which
later evolved into `ex`, forming the backbone of `vi` and `vim`, my favorite
editor).

Even more interestingly, about half of those substitutions--if not more--occur
on variables. But `bash` one-ups `sed` here. Invoking `sed` has to go through
the rigamarole of firing up an external process and using it correctly (which is
tricky even when you know `sed` syntax).

Solution: use parameter expansions.

```bash
a='foofoo'
echo "${a/foo/bar}" # barfoo
echo "${a//foo/bar}" # barbar
echo "${a%foo}" # foo
echo "${a^^}" # FOOFOO
```

See `man bash` for more incredible builtin solutions to your variable-editing
problems.

### Configure Isn't Thread Safe

Ok, so that probably seems obvious to anyone who's lived in a Linux world a long
time. I'm not exactly new to it, but this wasn't something I'd considered
previously.

As it turns out, I couldn't run my [parallel builds][] on the same machine
because they both needed to invoke `./configure` at the same time in the same
directory!

I ended up breaking it apart into two separate Jenkins jobs, which was pretty
easy since I'd moved the script logic for that into the main code as well. I
just had to set up the build job in the Jenkins instance, when it should run,
environment variables and all that, and kick it off.

PR merged, feature complete! I ended up saving about 10 minutes per build of the
repository I was working on.

## The Today Show: TIL

1. I may switch to TDD even while prototyping
2. Some vim and git stuff (see my [Dotfiles][])

If that seems like a short list, it's because I spent all day prototyping.

### Prototypes

I'm prototyping cake, the artifact-caching make-invoking build system I
designed. I've even got funny module names: `cake.recipe` for the configuration,
and I think `make` interaction will live in `cake.cooks` or `cake.chefs`, which
will become a centerpiece for extensibility (implement a custom cook or chef to
use something other than `make` to build your project).

However, I also spent a lot of time rewriting and rewriting code I was
prototyping. I spent more time thinking about the interface of the code, it's
testability, and just generally how I wanted it to look. I was thinking about a
lot of different concerns at once, and that tends to paralyze my brain until I
decide on the 'perfect' solution.

> Tip: The perfect solution does not exist.

#### Teddy Bear?

TDD is not a funny spelling of Teddy, nor is it an STD. It is a tool for
software developed described by a "red-green-refactor cycle". Essentially, one
can choose to code in the following steps:

1. Red: write a test that describes what your code should accomplish (it will
   probably fail--if it doesn't, lucky you).
2. Green: write the code necessary to make it pass
3. Refactor: leave it better than you found it (the Boy Scout method, or
   "refactoring")

This is Test Driven Development. Now, we still have to be careful not to place
too much value in the tests and to write *good* tests. But, the steps do require
some [pre-processing about API design and testability][tdd]. They also encourage
just getting the code out, and cleaning it up later.

The idea is that in the red phase, we focus on the features and the API. During
green, we Get Stuff Done™. During the refactor I can be obsessive about code
cleanliness, readability, extraction of functions and classes and things. But
half the API is already designed by the test: the public one. I can make
everything else private until it needs to be public.

Anyway, this style of context-switching should help me drop the
decision-paralysis of 'right the first time.'

I'm considering using this methodology to guide my decisions with further cake
prototyping.

---

P.S. Felicitations à la France, qui a gagné le Tour du Monde pour la première
fois depuis 1966 :fr: !

[parallel builds]: {% link _posts/2018-07-10-til-day-16--the-three-pieces-of-software.md %}
[Dotfiles]: {{ site.data.people.benknoble.github }}/Dotfiles
[tdd]: https://dmerej.info/blog/post/why-you-should-try-tdd/
