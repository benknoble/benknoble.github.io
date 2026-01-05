---
title: 'Little utilities'
tags: [shell, git]
category: [ Blog ]
---

Like many other full-time shell users, I write small utilities to add to my
toolbox. Let's compare.

**Update 2024 November 17:** Add notes on `git-q` and `git-vee`.

## Parallel thoughts

I stumbled on [MJD's blog](https://blog.plover.com/) via a [Git Rev
News](https://git.github.io/rev_news/) article from last year and found [a post
about little utilities](https://blog.plover.com/prog/runN.html). Clearly great
minds think alike:

- MJD explains an `f` command to extract a single field. It's written in Perl. I
  have a [`fields` script]({% link _posts/2019-09-11-fields.md %}) that uses
  dynamically-generated AWK to extract as many fields as you want. It's a longer
  name but useful in more situations.
- The post goes on to mention `runN`, a (mostly sequential but sometimes
  parallel) command runner that replaces some simple loops. But this is a
  straightforward variation on [moreutils](https://joeyh.name/code/moreutils/)
  `parallel` command[^1], so that's what I use when I remember to.

## Git

In [another post](https://blog.plover.com/prog/git-q.html), MJD mentions two Git
utilities:

- Using `git vee` as a wrapper around `git log` over a symmetric difference
  shows how branches have diverged. [My take, `git
  div`](https://github.com/benknoble/Dotfiles/commit/e0ca3d3402b00edb8ea3580afa1d171d07b6e246)
  infers the arguments that I would normally pass (like `base...upstream`) and
  allows to specify them, but the inference is intentionally unsophisticated. I
  consider this a companion to `git sbup` (`git show-branch HEAD HEAD@{upstream}
  HEAD@{push}`).
- Query object information with `git q`: [my
  take](https://github.com/benknoble/Dotfiles/commit/79a27b666323494b0fdcc82dbb1d0b5f73b556e2)
  is pure shell and only runs a single subprocess rather than one for each ref.
  This collapses equivalent refs but is ~50x more performant (see hyperfine
  output in the commit).

In the words of moreutils: there's room for more little unix utilities!

## Notes

[^1]: The [moreutils](https://joeyh.name/code/moreutils/) syntax and manual I
    vastly prefer to [GNU `parallel`](https://savannah.gnu.org/projects/parallel/),
    although GNU parallel supports niceties like a job log, retries, output
    syndication, etc. For "heavy lifting," I am forced to use GNU parallel (I
    try to write detailed notes on expected uses then), but for short one-liners
    I prefer the moreutils version.
