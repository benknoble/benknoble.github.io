---
title: 'Open-source Transparency'
tags: [ github, tmux, project-management, rants, open-source ]
category: [ Blog ]
---

My [first contribution][PR] to [tmux](https://github.com/tmux/tmux) was
accepted! Only, the history is not transparent.

The contribution itself is relatively trivial; I just added some keys to tmux's
`choose-tree` mode (invoked by commands like `choose-session`, bound to
<kbd>Prefix</kbd>-<kbd>s</kbd> by default). They keys are specifically intended
to align with vi-style bindings.

The loss of proper history is where I take issue. In the [PR][], I was following
up with patches from a [related
issue](https://github.com/tmux/tmux/issues/1846). The usual next steps are

1. verify the PR does what it should (code review, integration tests)
2. merge the PR

Step (1) was completed by acceptance from Travis CI and a [comment from
nicm](https://github.com/tmux/tmux/pull/1848#issuecomment-513135116).

Step (2) automatically closes the linked issue and integrates the code. The best
part is that GitHub provides links to trace back from the merge commit to the PR
to the issue, and a graphical history log (such as the Insights > Network tab on
GitHub) shows the merge from the fork. Tools like `git-log` and `git-blame` make
tracking these changes really easy. Finally, authorial information is correctly
capture (I authored the commits and their messages).

Instead, the same nicm did some form of a cherry-pick to another, separate fork,
squashed the commits, edited the message to put my name on them, and merged that
in via an unrelated process.

What?

Yes: `git-blame` now has a harder time pointing you back to my original PR or
issue.

Yes: authorial information is obliterated. nicm authored those commits. My name
is only incidentally attached (and, incidentally, I don't care about the credit:
I care about the *history*).

Yes: the history if FUBAR. It is effectively impossible to reconcile [nicm's
commit](https://github.com/tmux/tmux/commit/bf6d1aeaa44775923a72a4da49def96268dfa304)
with the original issue/PR sequence that led to it. Someone could do it, but one
feature of `git` (and GitHub) is to tie these things together in (publicly)
immutable history. No effort is needed to trace the history if merging is done.
Now it takes serious digging to connect these dots.

This is a broken software development process. I :heart: tmux and am writing in
vim in tmux right now, but this has me flabbergasted. Such a well-running
piece of software has creators that appear not to understand the value of git
history. [This is a regular pattern](https://github.com/tmux/tmux/network). The
only contributors to the code are effectively [nicm and
ThomasAdam](https://github.com/tmux/tmux/graphs/contributors). No one else
appears to have "contributed" since 2008 (or maybe the graphs are too tiny).

This is bad community.

So, to sum up: open-source projects *should*

- maintain correct (not necessarily *clean*) git history by using merges
properly
- value community and contributor support
- keep code, logs, bugs, and other supporting documents discoverable

They *should NOT*

- destroy git history for the sake of having a few trusted contributors
- fail to support the community that supports them
- obscure project history and information

[PR]: https://github.com/tmux/tmux/pull/1848
