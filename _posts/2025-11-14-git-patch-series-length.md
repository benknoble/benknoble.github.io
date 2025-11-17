---
title: Analyzing 10 years of accepted patch series to Git
tags: [git]
category: Blog
---

I was curious what length of patch series covered most of Git's accepted
patches. Here's my analysis.

**Update 2025 November 17th:** Junio C Hamano (Git maintainer) points out in the
comments that the structure I analyzed has a "cutoff" at 20 commits (see
c1b23bd8aa (Merge branch 'tb/incremental-midx-part-3.1', 2025-10-29) for a
longer example), so the tail of the analysis is incomplete. I'm going to update
the analysis, but so far a useful trick for those cases is

```shell
git log --after=10.years.ago | grep '^[[:blank:]]*\*.*[[:digit:]] commits'
```

First, in the following code, recall that I have the following function
definitions:

- `A() { awk "$@"; }` (autoloaded in Zsh)
- `frequency() { sort | uniq -c | sort -g; }` (see [Bash vs. Perl]({% link
  _posts/2019-09-27-perl-v-bash.md %}))
- You'll see a modified version of [`code-percent`'s cumulative tallying
  code]({% link _posts/2024-08-07-churn-and-weight.md %})
- I've got a [fields extracter]({% link _posts/2019-09-11-fields.md %})

My checkout of git.git's master branch is currently at fd372d9b1a (RelNotes: fix
typo in release notes for 2.52.0, 2025-11-13).

Our first goal is to count the length of a series. I've come up with 2 different
ways to do that:

1. Use the extremely regular structure of Git's merge commits to parse the
   length of the series. All merges have an asterisk-bulleted line followed by
   the list of commits being merged (single-patch series don't have a merge).
1. Or, use `git rev-list --count merge^..merge^2` to count the length of the
   series (commits not on first but on second parent). Unfortunately, this
   doesn't work well for non-merge commits. The syntax `merge^-` is better,
   since it expands as expected for merge commits and still gives the single
   commit when it's not a merge, but it overcounts merge commits by one, so we'd
   need extra processing there.

I've opted for the first version, but I'd be curious to see someone's code for
the 2nd that gave identical results.

We'll start just by pairing each `--first-parent` commit with a length; in the
final result, if we omit the commit identifier, we could probably shorten some
of the processing pipeline to a giant Awk script.

Here's the code:

```shell
git log --first-parent --since=10.years.ago | A 'BEGIN { count=0; }
NR > 1 && /^commit/ && !go { print "1" }
go && /^commit/ { print count; go=0; count=0; }
/^commit/;
go && /[^[:space:]]/ { count++; }
/^[[:space:]]+\*/ { go=1; }
END { if (go) print count }' | paste - -

commit fd372d9b1a69a01a676398882bbe3840bf51fe72	1
commit 99bd5a5c9f74abfe81196d96b8467d0d1d4723c5	1
commit 621415c8b5371a4734315232a780dd8282f6fe4f	1
commit e65e955c0328f6e1c4a7764ae86bbc875805e694	1
commit da5841b45c2b1cce79e0357218693061c2741780	1
commit cb9036aca1790d2258009d0db4c2991d972a07c2	1
commit 4badef0c3503dc29059d678abba7fac0f042bc84	6
commit e569dced68a486b38b14cdd2e3e0b34d21752a18	5
commit 5db9d35a28f4fca5d13692f589a3bfcd5cd896cb	1
commit f58ea683b53d78222937d66206ed66db1abffdd9	1
…
```

The Awk script runs a state machine. The variable `go` tracks whether we should
be counting lines towards the current patch series. So the rules are
- If we see a commit line (except the first) but we weren't tracking a patch
  series, the previous commit was a single-patch series. Emit "1".
- If we see a commit line and we are tracking a patch series, print the count
  and reset.
- Print all commit lines.
- While tracking a patch series, count lines that have a non-blank in them
- Start tracking when you see that line consisting of spaces followed by `*`
- At the end, print the final count (otherwise the last commit is omitted from
  analysis).

Paste just aligns the fields at the end for easy viewing.

## Barchart

Now we can take that and pipe it, keeping only the count, building up a
frequency chart by length of series, and make a barchart:

```shell
… | fields 3 | frequency | sort -n -k2 | barchart

0      1
1   5456 ███████████████████████████████████████████████████████████████████████
2   1073 ██████████████
3    618 ████████
4    384 █████
5    253 ███
6    217 ███
7    176 ██
8    122 ██
9    105 █
10   102 █
11    79 █
12    56 █
13    44 █
14    36
15    34
16    30
17    19
18    12
19    18
20    22
21   137 ██
```

What? A 0-length series? Turns out that's 995916e24f (Merge branch
'jk/avoid-redef-system-functions', 2022-12-19), which has a strange structure:

```
commit 995916e24f25644987f34b8a8e9392c0150804d8
Merge: efcc48efa7 395bec6b39
Author: Junio C Hamano <gitster@pobox.com>
Date:   Mon Dec 19 11:46:17 2022 +0900

    Merge branch 'jk/avoid-redef-system-functions'

    The jk/avoid-redef-system-functions-2.30 topic pre-merged for more
    recent codebase.

    * jk/avoid-redef-system-functions:

```

It's insignificant for the rest of the analysis though.

## Cumulative analysis

I want to know, though, how many patches cover a significant majority of the
lengths. Obviously the distribution skews towards the small end, but where's the
90% cutoff?

Take the same command as before, and pipe it into a modified cumulative tally.
We first map the counts per series length into a percentage-of-total per series
length (the middle line in the stages below). Then we sort by the series length
so we can run up the distribution in the expected order, emit a header for our
table, and emit the running tally before pretty-printing it.

```shell
… | fields 3 | frequency |
A '{ total += $1; counts[$2] = $1; } END { for (k in counts) print k, counts[k]*100/total; }' |
sort -n | { echo 'NumberPatches Percent CumulativePercent'; A '{ total += $2; print $0, total; }'; } | column -t

NumberPatches  Percent    CumulativePercent
0              0.0111185  0.0111185
1              60.6627    60.6738
2              11.9302    72.604
3              6.87125    79.4753
4              4.26951    83.7448
5              2.81299    86.5578
6              2.41272    88.9705
7              1.95686    90.9273
8              1.35646    92.2838
9              1.16744    93.4512
10             1.13409    94.5853
11             0.878363   95.4637
12             0.622637   96.0863
13             0.489215   96.5756
14             0.400267   96.9758
15             0.37803    97.3539
16             0.333556   97.6874
17             0.211252   97.8987
18             0.133422   98.0321
19             0.200133   98.2322
20             0.244608   98.4768
21             1.52324    100
```

So 7 patches covers 90% of contributions to Git in the last 10 years, and 5 (a
nice round number?) cover more than 85%. The interesting parts of the
distribution (the tails) don't change by more than about 1 percentage point if
we restrict ourselves to the 5 recent years of contribution history.
