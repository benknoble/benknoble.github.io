---
title: Rusty Boat Retrospective
tags: [ rust ]
category: [ Blog ]
---

Brief reflections on implementing Raft in Rust.

[Public code](https://github.com/benknoble/rusty-raft/).

## Raft

I hadn't thought about consensus algorithms since my MS year in 2020/2021, and
I'd certainly never thought deeply about them. Studying the paper and
Ousterhout's video presentations convinced me that implementing Raft ought to be
possible, in that same way that
[hubris](https://github.com/oxidecomputer/hubris) is necessary to take on
certain challenges. I was [demonstrably
humbled](https://github.com/benknoble/rusty-raft/commit/1d24310badc58dfc1fdd72e07813d584a3896990)
more than once[^1], but Raft's goal (as I understand it) is to be practically
implementable correctly.

The details matter immensely for correctness. Each statement is load-bearing.

As I wrote in the public README, there's little formal validation that my
implementation is faithful to any spec or upholds the relevant properties. I
have a few unit tests, but I haven't taken the dive on fuzzing or property
testing this code. It deserves it. (I probably won't try any proof tools, though
if memory serves creusot exists to fill that gap.[^2])

I especially enjoyed explicitly modelling an abstract Clock, which I did for one
of our warmup exercises during the course---it made some reasoning deliciously
simple. Its implementation is not perfect (a `sleep` loop doesn't really get you
precise ticking frequency), but a real example could tie into hardware clocks.

## Rust

This is my most extensive foray into Rust to-date, though I'd dabbled a bit
before. I like to say I can read Rust fairly well, having done that for years
now and especially due to the writings of Ralf Jung and others. I understand
a bit of the ideas Rust builds on, so I didn't find many ownership challenges
while writing this project---I intentionally structured the driver loop and main
algorithm so that who owned what data was clear, except for some fiddly bits
about sending application results around which end up just cloning.

I still stumble over some parts of Rust's module system, but that got easier
with time.

Rust's tools are great, of course.

I shied away from async Rust in this project; it seemed like too much to bite
off at the time. I'm more comfortable with message-passing threads from some Go
(years ago) and Racket (more recent), so I usually think in that model.

In a similar way, I didn't go dependency hunting here (I don't [browse crates.io
for fun](https://oxide-and-friends.transistor.fm/episodes/a-crate-is-born/transcript)).
I have serde for serialization, which ended up being more code than I thought I
would have to write (integrating with serde-lexpr to use S-expression formats),
and rand for randomness. There are likely other things that would be nice to
glue in, and for other projects dependencies are a necessity. Here I was mostly
satisfied with the standard library[^3].

I suspect my use of dependencies would look different if Rust's documentation
were integrated in the same way that [Racket's
is](https://docs.racket-lang.org), but I realize that's less practical for a
bigger ecosystem.

## Overall

I'm quite pleased I was able to implement such a fascinating system in a few
days of hard work: the essence was written between August 26th and 29th, with
less than 20 commits afterwards[^4]:

```
λ g dategraph
2025-08-26  13 ███████████████████
2025-08-27  28 ████████████████████████████████████████
2025-08-28  45 █████████████████████████████████████████████████████████████████
2025-08-29  42 █████████████████████████████████████████████████████████████
2025-09-20   1 █
2026-01-03   1 █
2026-01-04   2 ███
2026-01-05   1 █
2026-01-06   3 ████
2026-01-10   1 █
2026-01-19   3 ████
2026-02-03   4 ██████

λ DATEGRAPH=additions g dategraph
2025-08-26  652 ████████████████████████████████████████████████████████████████
2025-08-27  530 ████████████████████████████████████████████████████
2025-08-28  436 ███████████████████████████████████████████
2025-08-29  409 ████████████████████████████████████████
2025-09-20   11 █
2026-01-03    3
2026-01-04    8 █
2026-01-05   52 █████
2026-01-06   12 █
2026-01-19   45 ████
2026-02-03  204 ████████████████████
```

I'm also pleased I was able to return months later and reconstruct my thinking
without too much hassle. A few details were peculiar, but I've already forgotten
which ones!

And I can't resist[^5]:

```
λ g ls-files | code-percent
RowNumber  File                        PercentTotal  CumulativePercentTotal
1          src/lib.rs                  30.525        30.525
2          src/test_protocol.rs        26.2913       56.8163
3          src/main.rs                 11.3463       68.1626
4          README.md                   9.99153       78.1541
5          src/net.rs                  5.7155        83.8696
6          src/net/bytes.rs            5.63082       89.5005
7          src/test_append_entries.rs  4.65707       94.1575
8          start-cluster               1.31245       95.47
9          src/test_save_restore.rs    1.10076       96.5707
10         src/bin/client.rs           1.98984       98.5606
11         watch-cluster               0.127011      98.6876
12         start-client                0.127011      98.8146
13         src/net/config.rs           0.550381      99.365
14         .gitignore                  0.211685      99.5767
15         Cargo.toml                  0.42337       100
```

## Notes

[^1]: Try `git log --grep fix`.

[^2]: I have an old [incomplete proof of some supposed
    inverses](https://github.com/benknoble/advent2021/blob/prove-unflatten/day18/Day18.v)
    I'd like to finish, too… alas.

[^3]: Though not with the un-hashability of `mpsc::Sender`s.

[^4]: [`git-dategraph` script](https://github.com/benknoble/Dotfiles/blob/master/links/bin/git-dategraph)

[^5]: [`code-percent` discussion]({% link _posts/2024-08-07-churn-and-weight.md %})
