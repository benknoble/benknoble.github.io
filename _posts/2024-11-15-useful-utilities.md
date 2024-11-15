---
title: 'Little utilities'
tags: [shell]
category: [ Blog ]
---

Like many other full-time shell users, I write small utilities to add to my
toolbox. Let's compare.

## Parallel thoughts

I stumbled on [MJD's blog](https://blog.plover.com/) via a [Git Rev News]()
article from last year and found [a post about little
utilities](https://blog.plover.com/prog/runN.html). Clearly great minds think
alike:

- MJD explains an `f` command to extract a single field. It's written in Perl. I
  have a [`fields` script]({% link _posts/2019-09-11-fields.md %}) that uses
  dynamically-generated AWK to extract as many fields as you want. It's a longer
  name but useful in more situations.
- The post goes on to mention `runN`, a (mostly sequential but sometimes
  parallel) command runner that replaces some simple loops. But this is a
  straightforward variation on [moreutils](https://joeyh.name/code/moreutils/)
  `parallel` command[^1], so that's what I use when I remember to.

In the words of moreutils: there's room for more little unix utilities!

## Notes

[^1]: The [moreutils](https://joeyh.name/code/moreutils/) syntax and manual I
    vastly prefer to [GNU `parallel`](https://savannah.gnu.org/projects/parallel/),
    although GNU parallel supports niceties like a job log, retries, output
    syndication, etc. For "heavy lifting," I am forced to use GNU parallel (I
    try to write detailed notes on expected uses then), but for short one-liners
    I prefer the moreutils version.
