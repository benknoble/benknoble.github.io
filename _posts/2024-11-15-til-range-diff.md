---
title: 'Tip: use symmetric differences with git-range-diff'
tags: [git]
category: [ Blog ]
---

I've [been using `range-diff` for a while now]({% link
_posts/2024-10-04-copy-range-diff.md %}), but I'd been stuck with a long input
method for arguments. Today I learned a shortcut.

## Primer

Recall that `git range-diff` looks at the differences between two ranges:
commonly, we pass the two ranges explicitly; or, we can pass a base and two tips
to have the same effect as `<base>..<tip1> <base>..<tip2>`. The [manual
explaining this notation][range-diff-3-refs] gives the following example: "after
rebasing a branch `my-topic`, `git range-diff my-topic@{u} my-topic@{1}
my-topic` would show the differences introduced by the rebase." So I've been
writing

```
g range-diff @{u} @{1} @
```

and similar variants for several months. I actually recently switched to
[`push.default = current`][push-default] where my `@{upstream}` is the branch I
want to pull from (often some version of `origin/main` or `upstream/main`) and
Git provides (after I push) `@{push}` as the branch I'm pushing to (_e.g._,
`origin/topic`). With this layout, I run

```
g range-diff @{u} @{push} @
```

(There is no abbreviation for `@{push}`, sadly.)

## Symmetric diff

Now, I knew that `git range-diff` also accepts a [three-dot symmetric difference
notation][range-diff-sym-diff], so
```
g range-diff <left>...<right>
    -- becomes -->
g range-diff <right>..<left> <left>..<right>
```
But in the past, especially prior to `push.default = current`, I had not found
this terribly useful. I was probably holding it wrong.

Today, I write (before pushing)

```
g range-diff @{push}... | copy-range-diff
```

and all is well. Use `git log [--oneline] --graph --boundary --left-right --cherry-mark
@{push}...` to get a feel for what ranges are being compared.

[range-diff-3-refs]: https://git-scm.com/docs/git-range-diff#Documentation/git-range-diff.txt-ltbasegtltrev1gtltrev2gt
[push-default]: https://git-scm.com/docs/git-config#Documentation/git-config.txt-pushdefault
[range-diff-sym-diff]: https://git-scm.com/docs/git-range-diff#Documentation/git-range-diff.txt-ltrev1gt82308203ltrev2gt
