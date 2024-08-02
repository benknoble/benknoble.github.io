---
title: 'What everyone should know about git commit'
tags: [git]
category: [ Blog ]
---

These tips make it easier to write better commit messages.

1. Stop using `-m` (configure a proper editor)
1. Write while looking at the diff with `-v`

## Stop using `git commit -m`

Using `-m` encourages short commit messages that don't give meaningful
information. Did you know that omitting `-m` gives you a chance to write your
commit in your favorite editor? I think many people assume that `-m` is the only
way to avoid being dropped in to Vi (oh, the horror… [I guess]({% link
pages/about.md %})…), but you can [make Git use any editor you
want](https://git-scm.com/book/en/v2/Appendix-C%3A-Git-Commands-Setup-and-Config).
Now you have room to write those [standard formatted commit
messages](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).

The `-m` flag is convenient for `wip`-style save-my-progress commits that you'll
rebase and reword. You will reword them, won't you?

## Use `-v` to see your changes in the commit message template

You're writing your commit message and you want to review the changes to make
sure you commented on everything. What do you do?

- I run [`:DiffGitCached` with
  `\v`](https://github.com/benknoble/Dotfiles/blob/2ba059a73eb38b96225cc770f8e7d4d05b970306/links/vim/after/ftplugin/gitcommit.vim#L16),
  personally. Or `:Git --paginate diff --cached`.
- Use your terminal to do `git diff --cached`.
- Scroll to the bottom, because you used `--verbose`.

See that last one? If you need to, turn on `commit.verbose`; then Git will
include the diff in your commit message template for you to refer to.
