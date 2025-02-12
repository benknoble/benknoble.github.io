---
title: 'RE: the Commit Crunch: StackOverflow blog hosts naked corporate interests alongside misinformation'
tags: []
category: [ Blog ]
---

Following mention of a new diff algorithm in [Edition 114 of Git Rev
News](https://git.github.io/rev_news/2024/08/31/edition-114/), I dissect
problems with the post ["This developer tool is 40 years old: can it be
improved?"](https://stackoverflow.blog/2024/12/20/this-developer-tool-is-40-years-old-can-it-be-improved/).
I offer clarifications for the misinformation in the article, and I mention
free, builtin ways to get diff improvements.

## On dates

Bill Harding writes:

> Since IDEs are refreshed every few years, maybe you've guessed that your
> oldest tool in active use is "git." It was first released nearly 20 years ago,
> back in 2005. Or maybe you prefer to code with the classic old-school text
> editors, like Sublime Text (2008) or vim (1991).

Yet Vim and Git are under active development, getting "refreshed" perhaps more
regularly than other major (unnamed?) IDEs due to their distributed,
collaborative open-source practices. The core model may have changed little, but
Vim 9.1 in 2025 is not your 1991 Vim, nor is Git 2.48.1 in 2025 your Git from
2005.

It is true that the Myers diff algorithm (no air quotes necessary, thank you)
originates in 1986, but the colors on GitHub are not its byproduct; rather, I
believe an [edit script is the typical output]({% link
_posts/2020-08-06-stop-sed-i.md %}#addendum-scripting-ed). This is also
demonstrated on page 3, the same figure which Harding cites.

## On research

As Git Rev News mentions, Git supports other algorithms including
[`minimal`](https://github.com/git/git/commit/3443546f6),
[`patience`](https://github.com/git/git/commit/92b7de93fb7801), and
[`histogram`](https://github.com/git/git/commit/8c912eea94a). [Some research
exists on their properties]({% link _posts/2025-02-01-git-roundup.md %}#how-different-are-different-diff-algorithms-in-git).

This remains an active area of improvement, I believe.

## On diffs

Harding writes:

> The Myers diff algorithm classifies all code change lines as binary: either
> "add" or "delete."
>
> The Commit Cruncher algorithm tested recognizes three times more types of
> changed operations: Added, Deleted, Updated, Moved, Find/Replaced, and
> Copy/Pasted

Yet Git can detect moved lines with `--color-moved` (enable by default with
[`diff.colorMoved =
default`](https://github.com/benknoble/Dotfiles/blob/151d67dd2002f00d01c3f4fc1130815ae522116a/links/gitconfig#L101)).

Or consider

> One example where Myers requires more work by a reviewer is when a code change
> involves white space, like the change shown earlier in this post:

Yet Git has _several_ modes for making whitespace easier to review, like
`--ignore-space-change`, `--ingore-space-at-eol`, and `--ignore-all-space`. This
also typically shortcuts the complex changes from extracting methods, depending
on how far the new function is relocated. In Harding's example, I think
`--ignore-space-change` would produce a similar diff (but we'll never know
because sources for the diffs are not given).

Then there's "incremental updates" (whatever that means in this context):

> The same diff through a GitClear lens condenses the incremental update to a
> single line, where the new (or removed) characters are shown inline:

Git has a `--word-diff` mode that does the same thing and can be configured
per-invocation depending on where you want to consider interesting boundaries.
In my experience, it trivializes Harding's example diff, too.

Harding later tries to explain Commit Cruncher and writes:

> The Myers diff algorithm works by inspecting two inputs: the repo state before
> commit A and the state after commit C.

This is imprecise, just like the earlier formulation

> [Myers] offered what became the canonical solution for representing the
> difference between the state of a git repo “before” and “after” a developer’s
> git commit.

Git can generate diffs between blobs, trees, commits, and commit ranges. Harding
is either being intentionally imprecise (why?) or doesn't know much about Git's
diffs, the very thing his company's product is trying to improve.

## On presentation

I've written before that GitHub's UI has problems[^1], but this highlights one
more: GitHub has very poor support for examining diffs.

- GitHub does not natively support proper range-diffs. When a branch is
  force-pushed, GitHub only offers its standard difference between the commits,
  which shows a flat tree diff rather than a commit-by-commit comparison,
  including commit messages. In short, [you can't see how the PR evolved]({%
  link _posts/2025-02-01-git-roundup.md
  %}#reorient-github-pull-requests-around-changesets).
- GitHub doesn't support diff options beyond "ignore whitespace" (and I believe
  it tries to automatically do something akin to `--word-diff`). **This includes
  `--color-moved` for showing moved lines.** In practice, developers creating
  commits may have a good idea about how to communicate the diff ([I and others
  have experimented with communicating these options in
  commits](https://lore.kernel.org/git/CALnO6CDqHJP_wa_8eKHBkU+_1vQ6D+C=QRZyW1FKnG71wDxnnQ@mail.gmail.com/)).

Improving these situations or moving away from GitHub as your primary diff
viewer would be free alternatives to a Harding's tool.

## In conclusion

The StackOverflow blog shamelessly shills for a company to get you to buy a
product you probably don't need. What's new?

## Notes

[^1]: [PR reviews]({% link _posts/2024-10-04-copy-range-diff.md %}) lack
    [threading]({% link _posts/2025-02-01-git-roundup.md
    %}#reorient-github-pull-requests-around-changesets), and it has [bad
    defaults for some kinds of merges]({% link
    _posts/2024-08-02-github-squash.md %}).
