---
title: Analyzing 10 years of accepted patch series to Git
tags: [git]
category: Blog
---

I was curious what length of patch series covered most of Git's accepted
patches. Here's my analysis.

**Update 2026 February 23rd:** Git-for-Windows maintainer Dscho sent me some
interesting data, which I've added [near the end of the
post](#a-different-analysis).

**Update 2025 November 17th:** Junio C Hamano (Git maintainer) points out in the
comments that the structure I analyzed has a "cutoff" at 20 commits (see
c1b23bd8aa (Merge branch 'tb/incremental-midx-part-3.1', 2025-10-29) for a
longer example), so the tail of the analysis is incomplete. I'm going to update
the analysis, but so far a useful trick for those cases is

```shell
git log --first-parent --after=10.years.ago | grep '^[[:blank:]]*\*.*[[:digit:]] commits'
```

**Update later that day:** I've corrected the analysis below after confirming
that all 137 "21-length series" are correctly counted as larger series. See
Git history for the old version of this post.

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

There's one caveat for item (1) here: the structure comes from `merge.log=true`
configuration and cuts off series that are longer than 20 commits. So we'll do
some extra processing on the bulleted line to grab the size.

We'll start just by pairing each `--first-parent` commit with a length; in the
final result, if we omit the commit identifier, we could probably shorten some
of the processing pipeline to a giant Awk script.

Here's the code:

```shell
git log --first-parent --since=10.years.ago | A 'BEGIN { count=0; }
NR > 1 && /^commit/ && !go && !big { print "1" }
go && /^commit/ { print count; go=0; count=0; }
/^commit/ { big=0; print $0; }
go && /[^[:space:]]/ { count++; }
/^[[:space:]]+\*/ { go=1; }
/^[[:space:]]+\*.*[[:digit:]] commits/ {
    big=1; go=0
    n_pieces = split($0, pieces, ":")
    match(pieces[n_pieces], "[[:digit:]]+")
    print substr(pieces[n_pieces], RSTART, RLENGTH)
}
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
- If we see a commit line (except the first) but we weren't tracking a (big)
  patch series, the previous commit was a single-patch series. Emit "1".
- If we see a commit line and we are tracking a patch series, print the count
  and reset.
- Print all commit lines (resetting `big` as we go).
- While tracking a patch series, count lines that have a non-blank in them
- Start tracking when you see that line consisting of spaces followed by `*`
- If you see a `*` line that ends contains digits followed by `commits`, use the
  count from there and mark it `big` (so we can skip printing "1")
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
21    16
22    22
23    13
24     8
25     8
26     9
27     7
28     7
29     5
30     4
31     1
32     4
33     3
34     3
35     2
36     3
37     1
38     6
39     1
41     2
42     2
44     1
45     1
46     2
47     1
49     1
50     1
53     1
81     1
92     1
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
sort -n |
{ echo 'NumberPatches Percent CumulativePercent'; A '{ total += $2; print $0, total; }'; } |
column -t

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
21             0.177896   98.6547
22             0.244608   98.8993
23             0.144541   99.0439
24             0.0889482  99.1328
25             0.0889482  99.2218
26             0.100067   99.3218
27             0.0778297  99.3997
28             0.0778297  99.4775
29             0.0555926  99.5331
30             0.0444741  99.5776
31             0.0111185  99.5887
32             0.0444741  99.6331
33             0.0333556  99.6665
34             0.0333556  99.6999
35             0.022237   99.7221
36             0.0333556  99.7555
37             0.0111185  99.7666
38             0.0667111  99.8333
39             0.0111185  99.8444
41             0.022237   99.8666
42             0.022237   99.8889
44             0.0111185  99.9
45             0.0111185  99.9111
46             0.022237   99.9333
47             0.0111185  99.9445
49             0.0111185  99.9556
50             0.0111185  99.9667
53             0.0111185  99.9778
81             0.0111185  99.9889
92             0.0111185  100
```

So 7 patches covers 90% of contributions to Git in the last 10 years, and 5 (a
nice round number?) cover more than 85%. The interesting parts of the
distribution (the "left" or "top" tail) don't change by more than about 1
percentage point if we restrict ourselves to the 5 recent years of contribution
history, though on the "right"/"bottom" tail we stop at series with a maximum
length of 49.

## A different analysis

Dscho sent me a script that does a better job counting. To test it and look for
discrepancies, I first made sure I could replicate my original data:

```shell
git log --first-parent --since='17th November 2015 13:52:48-0500' | A 'BEGIN { count=0; }
NR > 1 && /^commit/ && !go && !big { print "1" }
go && /^commit/ { print count; go=0; count=0; }
/^commit/ { big=0; print $0; }
go && /[^[:space:]]/ { count++; }
/^[[:space:]]+\*/ { go=1; }
/^[[:space:]]+\*.*[[:digit:]] commits/ {
    big=1; go=0
    n_pieces = split($0, pieces, ":")
    match(pieces[n_pieces], "[[:digit:]]+")
    print substr(pieces[n_pieces], RSTART, RLENGTH)
}
END { if (go) print count }' | paste - - | fields 3 | frequency | sort -n -k2 | barchart
```

Unfortunately, this produces a few differences… but it's close. In particular, I
noticed that this now counts (starting from the same commit, mind you!) 1072
2-patch series and 254 5-patch series (1 less and 1 more, respectively):

```
0      1
1   5456 ███████████████████████████████████████████████████████████████████████
2   1072 ██████████████
3    618 ████████
4    384 █████
5    254 ███
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
16    29
17    19
18    13
19    18
20    22
21    16
22    22
23    13
24     8
25     8
26     9
27     7
28     7
29     5
30     4
31     1
32     4
33     3
34     3
35     2
36     3
37     1
38     6
39     1
41     2
42     2
44     1
45     1
46     2
47     1
49     1
50     1
53     1
81     1
92     1
```

Here is Dscho's Node script, which I am supposed to run like

```shell
git rev-list --parents --topo-order --boundary --since='17th November 2015 13:52:48-0500' @ |
    ./patch-series-analyzer.js 92
```

```javascript
#!/usr/bin/env node

const readline = require('readline');

// Set of commits in the first-parent chain
const firstParentCommits = new Set();

// Map from commit to its corresponding first-parent merge commit
const commit2merge = new Map();

// Map from merge commit to { count: number, mergeCommitCount: number }
const mergeCommitInfo = new Map();

// Array of first-parent merge commits (in order encountered)
const firstParentMerges = [];

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
});

rl.on('line', (line) => {
  const [commit, ...parents] = line.trim().split(/\s+/);

  if (commit.startsWith('-')) {
    const commit2 = commit.slice(1);
    if (!firstParentCommits.has(commit2)) {
      const merge = commit2merge.get(commit2);
      if (merge) mergeCommitInfo.get(merge).incomplete = true;
    }
    return;
  }

  if (firstParentCommits.size === 0) firstParentCommits.add(commit);

  if (firstParentCommits.has(commit)) {
    if (parents.length > 0) firstParentCommits.add(parents[0]);
    if (commit === '15664a5f35b6db8077e3e8aeb377e72f0f95e23e') ; // ignore criss-cross merge
    else if (parents.length > 1) {
      // This is a merge commit in the first-parent chain
      firstParentMerges.push(commit);
      mergeCommitInfo.set(commit, { commit, count: 0, mergeCommitCount: 0 });
      parents.slice(1).forEach(parent => {
        const merge = commit2merge.get(parent);
        if (merge) merge.doubleCountedAncestors = true;
        commit2merge.set(parent, commit);
      });
    }
  } else {
    const merge = commit2merge.get(commit);
    if (merge) {
      const info = mergeCommitInfo.get(merge);
      if (parents.length === 1) info.count++;
      else if (parents.length > 1) info.mergeCommitCount++;
      parents.forEach((parent) => {
        const merge2 = commit2merge.get(parent);
        if (merge2) merge.doubleCountedAncestors = true;
        commit2merge.set(parent, merge);
      })
    }
  }
});

rl.on('close', () => {
  printResults();
});

function printResults() {
  firstParentMerges.sort((a, b) =>
    a.mergeCommitCount !== b.mergeCommitCount
    ? a.mergeCommitCount - b.mergeCommitCount
    : a.count - b.count);

  const stats = firstParentMerges.reduce((a, merge) => {
    const info = mergeCommitInfo.get(merge);
    if (!info || info.mergeCommitCount || info.doubleCountedAncestors || info.incomplete) return a;
    a.set(info.count, 1 + (a.get(info.count) || 0));
    return a;
  }, new Map());
  const sorted = [...stats.entries()].sort((a, b) => a[0] - b[0]);

  console.log('Patch Series Length Analysis:');
  console.log('==============================');
  console.log('Length |      Count | Distribution');
  console.log('-'.repeat(60));

  if (sorted.length === 0) {
    console.log('No merge commits found.');
    return;
  }

  const maxCount = Math.max(...sorted.map(([_, count]) => count));

  for (const [length, count] of sorted) {
    const barLength = Math.floor((count / maxCount) * 50);
    const bar = '█'.repeat(barLength);
    console.log(`${length.toString().padStart(6)} | ${count.toString().padStart(10)} | ${bar}`);
  }

  console.log();
  console.log('Summary:');
  console.log('--------');

  const total = sorted.reduce((sum, [_, count]) => sum + count, 0);
  let cumulative = 0;
  let found50 = false;
  let found90 = false;

  for (const [length, count] of sorted) {
    cumulative += count;
    const percentage = (cumulative / total) * 100;

    if (!found50 && percentage >= 50) {
      console.log(`50% of series have ${length} or fewer commits`);
      found50 = true;
    }
    if (!found90 && percentage >= 90) {
      console.log(`90% of series have ${length} or fewer commits`);
      found90 = true;
    }
  }

  console.log(`Total merge commits analyzed: ${total}`);

  process.argv.slice(2).forEach((arg) => {
    const n = Number.parseInt(arg);
    console.log(`${n}:`, firstParentMerges.filter((merge) => {
      const info = mergeCommitInfo.get(merge);
      return info && info.count === n && info.mergeCommitCount === 0 && !info.doubleCountedAncestors && !info.incomplete
    }));
  })
}
```

And here are the results (it is _much_ quicker than my method):

```
Patch Series Length Analysis:
==============================
Length |      Count | Distribution
------------------------------------------------------------
     0 |         12 |
     1 |       4314 | ██████████████████████████████████████████████████
     2 |       1040 | ████████████
     3 |        584 | ██████
     4 |        360 | ████
     5 |        232 | ██
     6 |        200 | ██
     7 |        158 | █
     8 |        105 | █
     9 |         97 | █
    10 |         88 | █
    11 |         69 |
    12 |         41 |
    13 |         36 |
    14 |         28 |
    15 |         26 |
    16 |         23 |
    17 |         15 |
    18 |         10 |
    19 |         13 |
    20 |         15 |
    21 |         12 |
    22 |         16 |
    23 |         10 |
    24 |          6 |
    25 |          2 |
    26 |          6 |
    27 |          4 |
    28 |          4 |
    29 |          4 |
    30 |          3 |
    31 |          1 |
    32 |          2 |
    33 |          3 |
    34 |          3 |
    35 |          2 |
    36 |          3 |
    37 |          1 |
    38 |          3 |
    39 |          1 |
    41 |          2 |
    42 |          1 |
    44 |          1 |
    45 |          1 |
    46 |          1 |
    47 |          1 |
    50 |          1 |
    53 |          1 |
    92 |          1 |

Summary:
--------
50% of series have 1 or fewer commits
90% of series have 7 or fewer commits
Total merge commits analyzed: 7562
92: [ 'e572fef9d459497de2bd719747d5625a27c9b41d' ]
```

Notice all the discrepancies (and I'd be more inclined to trust this script
parsing Git's actual parents)! This counts 7562 series. My version counted 8994
series. So maybe that accounts for some things… other than the 0-length series,
I think Dscho's counts are all smaller than mine.

Dscho also sent some other interesting data:

> The answer to [What on Earth could this patch series be that was accepted
> despite consisting of 92 (!!!) patches] is this: [Compare on
> GitHub](https://github.com/git/git/compare/e572fef9d459497de2bd719747d5625a27c9b41d%5E...e572fef9d459497de2bd719747d5625a27c9b41d).
> Rather a monster of a patch series, I thought. But then I discovered that it
> was not sent as a single patch series, but as [nine separate
> ones](https://lore.kernel.org/git/1452599378-47882-1-git-send-email-gitter.spiros@gmail.com/).
>
> The contributions became more civil this year (at least the ones that were merged):
>
> ```
> Length |      Count | Distribution
> ------------------------------------------------------------
>      1 |        311 | ██████████████████████████████████████████████████
>      2 |         82 | █████████████
>      3 |         40 | ██████
>      4 |         31 | ████
>      5 |         25 | ████
>      6 |         20 | ███
>      7 |         12 | █
>      8 |          7 | █
>      9 |         12 | █
>     10 |          8 | █
>     11 |          3 |
>     12 |          4 |
>     13 |          4 |
>     14 |          2 |
>     16 |          2 |
>     17 |          1 |
>     18 |          1 |
>     20 |          1 |
> ```
>
> (The 20-strong patch series corresponds to
> [ps/test-wo-perl-prereq](https://git.kernel.org/pub/scm/git/git.git/commit/?id=9bdd7ecf7ec90433fc1803bf5d608d08857b3b49).)

Thanks, Dscho! If anyone can figure out why the counts are so different between
the approaches, I'm all ears :)
