---
title: 'Churn and Weight'
tags: [ project-management, git, frosthaven-manager, racket ]
category: [ Blog ]
---

I examine a metric that might be correlated with churn, and I posit a new
concept for code bases called weight. I also call attention to 2 tools for
measuring churn and weight.

## Churn

Churn is an attribute of functions and modules: those which tend to change
frequently are said to undergo heavy churn. This is typically a symptom of tight
coupling.

Measuring churn can be done, for example, by looking at how often files change
in Git history. In 2018 I stole [Gary Bernhardt's
`git-churn`](https://github.com/garybernhardt/dotfiles/blob/main/bin/git-churn)
and [made it my
own](https://github.com/benknoble/Dotfiles/blob/master/links/bin/git-churn). For
example, here's what it says on Frosthaven Manager:

```shell
# git churn | head
 117 scribblings/reference.scrbl
 101 server.rkt
  94 gui/manager.rkt
  90 gui/monsters.rkt
  77 defns.rkt
  73 info.rkt
  66 monster-db.rkt
  49 manager/state.rkt
  44 manager.rkt
  35 elements.rkt
```

Unsurprisingly, the reference documentation and web server change the most
frequently, followed closely by 2 of the largest and most important GUI
components (the composite whole and the monsters). The reference documentation
changes whenever a module is added, moved, or renamed, and the web server is
changing rapidly in response to player feedback.

Let's examine a related idea: _weight_.

## Weight

I'm using the word "weight" to refer to both how heavy a module or function is
in terms of essential complexity and to how load-bearing it is in terms of
making the system do what it does. In a mature project, we probably expect to
find a few core modules to be heavy, with a (possibly long) tail of light
supplements.

Since heavy modules often sit at the core of the system, they are likely to have
either lots of churn (frequent changes to the core system) or little (a stable
core with frequent changes to the supplements). In other words, churn on heavy
core modules can give us an idea of how stable our core is: having the wrong
core design is a serious challenge to the life of the project.

How do we measure weight? As a start, I'll use _relative percentages of the
code._ This sounds like lines of code, but it has a subtle difference: 10k lines
of code is only 1% of a codebase with 1 million lines, but dwarfs any system
with a mere few hundred. It's not size that matters, it's relative size.

Using my
[`code-percent`](https://github.com/benknoble/Dotfiles/blob/master/links/bin/code-percent)
program, we can tabulate relevant percentages and their cumulative effects.
Here's how it runs on Frosthaven Manager:

```shell
# git ls-files | code-percent
RowNumber  File                                      PercentTotal  CumulativePercentTotal
1          server.rkt                                7.47149       7.47149
2          gui/monsters.rkt                          6.37762       13.8491
3          scribblings/programming-scenario.scrbl    4.56775       18.4169
4          manager/state.rkt                         3.9048        22.3217
5          defns/monsters.rkt                        3.62636       25.948
6          gui/manager.rkt                           2.87059       28.8186
7          gui/player-info.rkt                       2.27393       31.0925
8          gui/markdown.rkt                          2.11482       33.2074
9          elements.rkt                              1.93583       35.1432
10         scribblings/how-to-play.scrbl             1.9292        37.0724
# [snip]
162        README.md                                 0.0265182     100
```

This gives a different picture of the code. The reference has disappeared
(supplanted by large documents), being a mere 30 lines relative to the 15k
total. But a few core pieces of functionality (state, game definitions, and GUI
pieces) have drifted to the surface, collectively taking up roughly one third of
the size of the code. Indeed, we might now question if `gui/markdown.rkt`, which
implements a "good enough for me" Markdown-to-GUI-text widget, is holding its
weight. Conversely, it might be time to try refactoring the server or monsters
GUI again. The server is not core in the layering of pieces, but it is core to
the app's experience. It might even contain its own core of domain pieces, which
explains its weight.

One other trick we can do: we can get a neat idea of the size of the tail by
showing only the rows that bump us over major (cumulative) thresholds. For
example:

```shell
# git ls-files | code-percent | awk 'BEGIN { target = 25; } NR == 1 { print; next; } $4 >= target { print; target += 25; }'
RowNumber  File                                      PercentTotal  CumulativePercentTotal
5          defns/monsters.rkt                        3,62636       25,948
19         defns/scenario.rkt                        1,18006       50,3116
50         gui/table.rkt                             0,550252      75,4243
162        README.md                                 0,0265182     100
```

While the first 5 files account for 25% of the code, it takes almost another 15
to reach 50%, then another 30 to reach 75% followed by a whopping 110 to
conclude. This matches at least our expectation of a long tail.
