---
title: I am not the first to notice GitHub's range-diff deficiency; I will not be the last
tags: [ git ]
category: [ Blog ]
---

Scott Chacon of Pro Git fame is writing about Git again: this time, with (yet
another) take on how the company he helped build might be doing it wrong.

In [How to do patch-based review with git
range-diff](https://blog.gitbutler.com/interdiff-review-with-git-range-diff/),
Chacon covers the ground on how to perform review in terms of versions of a
branch, stuff Git developers have been doing for years. See [my own primer]({%
link _posts/2024-10-04-copy-range-diff.md %}#primer) for details on the
workflow, especially with GitHub involvement. What's particularly great about
Chacon's post for GitButler is its link to [Why some of us like "interdiff" code
review](https://gist.github.com/thoughtpolice/9c45287550a56b2047c6311fbadebed2).

This blog post-né-Gist captures many of my own recent thoughts about GitHub:

- GitHub's UI actively encourages suboptimal development technique[^1]. In
  practice, that means "diff soup" and "lack of solid tools for reviewers
  outside of the comment interface."
- In particular, implicit relationships and information loss abound, which sucks
  for reviewer and future code spelunker.
- GitHub encourages _branch- and merge- heavy thinking_. These are not
  necessarily even the easy parts of Git! They can be for a solo developer just
  getting started, but in true distributed settings come with their own
  challenges.
- Interdiff reviewing requires more knowledge of Git than is typical or average
  (based on my own unscientific view of lots of colleagues), and thus would
  benefit more from UI help than typical branch and merge operations.

It is nice to have language to talk about this. I can just see myself writing
"Please stop feeding me [diff
soup](https://gist.github.com/thoughtpolice/9c45287550a56b2047c6311fbadebed2?ref=blog.gitbutler.com):
I don't need a feast, but I would like some seasoning." (Accompanied, of course,
by details on how to improve!)

PS Chacon's article mentions that you'll often need to note an original hash or
find one in the reflog to compare the old branch version to the new branch
version. For `git range-diff` superpowers, try [using `git range-diff @{u}
@{push} @` to see what's changed since you pushed]({% link
_posts/2024-11-15-til-range-diff.md %}#primer).

## Notes

[^1]: See [how GitHub can't show cross-version changes]({% link
    _posts/2024-10-04-copy-range-diff.md %}), [Reorient GitHub Pull Requests
    Around Changesets](https://mitchellh.com/writing/github-changesets) and
    commentary in [A grab-bag of Git links]({% link
    _posts/2025-02-01-git-roundup.md %}), a rant about [PR merge messages]({%
    link _posts/2024-08-02-github-squash.md %}), and [notes on GitHub's diff UI
    presentation]({% link _posts/2025-02-10-stackoverflow-github-corporate-interest.md %}#on-presentation).
