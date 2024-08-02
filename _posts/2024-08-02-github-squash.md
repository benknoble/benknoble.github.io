---
title: 'The case against squashing to merge via GitHub'
tags: [git, rants]
category: [ Blog ]
---

Squash and merge is a bad default action, and it grates when it's the _only_
permitted merge option.

Squash and merge collapses even carefully crafted PRs and commits into a giant
blob (pun intended). All the juicy information we know how to unlock with tools
like `git log` and `git blame` is now gone, made useless by the squash. It even
hurts `git bisect`: pinpointing a squashed merge is unlikely to help if you
still have to wade through 6000 lines of changes instead of 600 or 60. Even if
you can recover the original branch using GitHub's `refs/pull/N/head` namespace,
which isn't guaranteed on other vendors, it can still be harmful to hit the
squash fence.

Worse, squashing to merge traps you in a vicious cycle. In an ideal world, good
commits help us fall into a virtuous cycle of success: they provide more
information so that our tools are more useful, which encourages us to use our
tools more, which reveals more opportunities to pack information into commits,
and so on. Meanwhile, squashing everything by default traps us in the antithesis
of this cycle—commit messages are useless if they'll be squashed, so they become
useless in a self-fulfilling prophecy, encouraging squash and merge ad nauseum.
We remove incentives to use our information-gathering tools; not using them
blinds us to their power, keeping them from being useful.

No other investment that we make pays off as long as good commits. Good commits
pay dividends for the entire lifetime of a project and become more valuable the
longer the project lives. This might as well be an exponential curve of payoff.
Nothing is free, but the expected value of any single commit dwarfs the cost of
the minutes involved in crafting its message. Squash and merge as a default
eliminates those benefits and any incentives to reap them. Outside of a few
narrow use cases, I recommend against it.

Discuss with your teams and projects: decide what's right for you. Don't default
to squash and merge because it seems easy or commonplace. One of the trade-offs
is giving up useful commits (unless whoever merges takes the time to craft a
good squash message, which in many circles is rare thanks to GitHub defaults).
If you intentionally choose this trade-off, you probably needing to be getting
equivalent dividends from whatever the other trade-offs are. The benefits of
commits are hard to measure up against.

One case squash might be useful: squashing messy external contributions gives
maintainers an expedient way to accept otherwise good code and bring the commit
up to project standards. Ideally this is paired with resources for the
contributor to learn how to do better next time, including both Git knowledge
and project standards knowledge. Mentoring a new contributor through the process
to fix the commits themselves is a valuable and laudable task, but it is costly.

On the other hand, moving slowly is not so bad as it seems, despite all FAANG
would have you believe.

Don't forget: GitHub foisted the squash and merge option upon us with bad
defaults to back it up. To do the equivalent in Git requires knowledge of
interactive rebase or the `cherry-pick` command. Git knows how to merge and
rebase via commands of the same name and flags to `pull`. Squash and merge is a
convenient button when needed, but the need is so infrequent that its only
mention in Git proper is the `squash` verb in the lexicon of interactive rebase.

You tread this route at your own peril.
