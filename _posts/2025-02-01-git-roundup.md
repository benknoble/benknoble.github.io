---
title: 'A grab-bag of Git links'
tags: [ git ]
category: [ Blog ]
---

Some reflections on a mass of articles taking up space on my phone.

## [How I use Git worktrees](https://matklad.github.io/2024/07/25/git-worktrees.html)

Matklad explains what to me is a novel application of worktrees. Git's own
[manual page](https://git-scm.com/docs/git-worktree#_examples) talks about them
like a better stash, but Matklad uses them to organize parallel tasks that want
their own sources and builds:

- `project/`
    - `main`: the current `main` branch of development
    - `work`: active work
    - `review`: PR review
    - `fuzz`: fuzzing with Zig
    - `scratch`: random fixups

While I probably wouldn't personally use a `main` worktree just for diffing,
since `git diff` can do that already, using it to compare build times and
behavior is smart. My current projects don't need fuzzing, and I tend to make
"scratch" work by throwing it into my
[notepad](https://github.com/benknoble/Dotfiles/blob/6a07c3fb97067eed575bc26042ef9dc945301efb/links/vim/autoload/bk/notepad.vim)
[wiki](https://github.com/benknoble/Dotfiles/blob/6a07c3fb97067eed575bc26042ef9dc945301efb/links/vim/after/plugin/config/wiki.vim#L43-L45)
and coming back to it later. Still, I could imagine setting up 3 or 4 tmux
windows per project in different worktrees, or just one and using
`pushd`/`popd`. Build systems that use last-modified times, like `make`, would
probably re-build less stuff in the main worktree than in my chaotic work or
review worktrees, so that could help.

## [commit messages are optional](https://schpet.com/note/git-commit-messages-are-optional)

If you know me, you know I don't agree with the title on principle, but:
technically you can use empty commit messages with `--allow-empty-messages`. And
the author smartly uses this for a workflow that includes lots of transient
commits (not dissimilar to one I use myself), where the final commits get a nice
message.

My personal version of this is usually `git commit -m.` or `git commit -m wip`,
which don't jar quite as much in `git log` and similar output.

## [Reorient GitHub Pull Requests Around Changesets](https://mitchellh.com/writing/github-changesets)

I'm not the only one to think [GitHub PR reviews have problems]({% link
_posts/2024-10-04-copy-range-diff.md %}): for one, the lack of real threading
[like in email](https://drewdevault.com/2018/07/02/Email-driven-git.html) makes
pages with lots of comments abysmally slow, and the diff + comment interface is
no better for even reasonably sized PRs! Meanwhile, the underlying Git
technology is _fast_.

Mitchell Hashimoto focuses more on the lifecycle problems with GitHub's
interface, though: primarily the distinct lack of versioning (again, something
email and `git range-diff` support natively) and the problem of working on the
reviews and the responses in parallel. Like many of us, he wishes GitHub could
orient itself around versioned changesets.

Fortunately, this is what [SourceHut](https://sr.ht) does, and I keep coming up
with new reasons to try it.

## [Tips for creating merge commits](https://www.brandonpugh.com/blog/tips-for-creating-merge-commits/)

Brandon Pugh's first line of advice is one I've oft repeated: _make the commit
message as useful as possible_. As he points out, we talk a lot about regular
commits but less about merge commits. I've [ranted about messages in PR
merges]({% link _posts/2024-08-02-github-squash.md %}), but not explained that

- I like to use [the "Conflict" comments Git
  adds](https://github.com/benknoble/requirements.txt.vim/commit/c4383604c34787e0151c3f9b0325b1aa5565ff2d)
  to explain their source and resolution.
- I use [`merge.log =
  true`](https://github.com/benknoble/Dotfiles/blob/6a07c3fb97067eed575bc26042ef9dc945301efb/links/gitconfig#L114)
  to include the 20 most recent commits in the merge commit summary. Similarly
  you could use `merge.branchdesc` to populate messages with branch descriptions
  if your workflow often includes setting those.

Pugh also points out there's often other explanations that can be given in the
description, and we should probably do that.

And of course, avoid evil merges.

## [Store code discussions in Git using Git notes](https://wouterj.nl/2024/08/git-notes)

Wouter's primer on notes is one of the better ones I've seen because it
explicitly covers note namespaces and refspecs, making them easier to work with.
In fact, I'm now tempted to start putting notes on commits at work and pushing
them, just in case someone ever discovers them ;)

Unfortunately, I can't find any options to make adding the "fetch all notes"
refspec the default when setting up new remotes (or cloning). Although it is
possible to create default refspecs for pushing, that also overrides
`push.default` which is useful for [making Git DWIM in a triangular workflow]({%
link _posts/2024-11-15-til-range-diff.md %}#primer).

## [How Different Are Different diff Algorithms in Git?](https://cs.paperswithcode.com/paper/how-different-are-different-diff-algorithms)

I haven't had time to read this yet, but it seems like it could be a good
reference on the diff algorithms themselves. They are one aspect of Git I've
never really explored.

## [Not rocket science rule applies to merge commits](https://matklad.github.io/2023/12/31/git-things.html#Not-Rocket-Science-Rule-Applies-To-Merge-Commits)

Another Matklad piece: _typical projects don't need a linear history of every
commit passing tests_. In such a project, merges are the record of passing tests
(so `bisect` with `--first-parent` first). Take advantage of this by structuring
commits in branches to split work. Matklad gives several examples.

Matklad also mentions the "merge to main, rebase feature branches"
workflow---here, you still rebase feature branches if you need to build on top
of later commits, but you create merge commit when bring the branch into main.

Oh, and by the way: **stop commenting out dead or broken code**[^1]. Delete it. We
can recover it with version control (and it's likely to never be fixed or
recovered anyway).

## [Commit messages](https://matklad.github.io/2023/12/31/git-things.html#Commit-Messages)

More Matklad: small and trivial changes deserve small, trivial commit messages.
And we should try to make more of them.

Bait taken! You know I like a good long commit message, but it's absolutely true
that big commits are a workflow problem often imposed by CI + review turnaround.
I've worked with plenty of folks who wish they could do differently but who know
that they need to squeeze as much as they can out of each PR because turnaround
time is long.

Yikes.

I like most of Matklad's recommendations for fixing the workflow problem here,
though of course in some regulated industries merging pre-review is a
non-starter.

I will single out one comment:

> If a change is really minor, I would say `minor` is an okay commit message!

No, it isn't: the subject should describe the fix, even if it's just `fix doc
typo` or `s/it's/its`. Those still convey the "minor" intent while providing
enough detail to folks fetching new changes to know what's happening around
them.

## [Unified versus split diff](https://matklad.github.io/2023/10/23/unified-vs-split-diff.html)

Guess I'm reading a lot of Matklad lately.

The "better diff for review" idea is novel to me, and certainly seems like a
good one to try building! But I'm rather more interested in fetching PR changes
for review and then resetting them so that
[vim-fugitive](https://github.com/tpope/vim-fugitive) can show them to me. I
normally review one commit at a time, so this might be a good inter-commit
workflow. It also helps provide an overview. Interesting.

In the end, whether by email or web UI, we're still leaving comments on the
diffs, though.

## [Two kinds of code review](https://matklad.github.io/2021/01/03/two-kinds-of-code-review.html)

This one reminded me of times where I've accepted PRs from newer contributors by
fixing up their branches and merging locally---hopefully that provided some
lessons for them, but it might not be as teachable as merging followed by fixes
(cc'ing them). At least, in prior applications where I didn't show them the
range-diff and walk them through the changes I made, I certainly didn't
_actively_ teach them.

## [Putting the I back in IDE: towards a GitHub explorer](https://blog.janestreet.com/putting-the-i-back-in-ide-towards-a-github-explorer/)

JaneStreet describes an internal review and workflow tool, and I'm jealous.

It did inspire me to add a personal todo item: try building a Vim plugin for
reading and writing PR review comments! I've explored a little of the prior
work, but it's deep in my personal backlog.

## [Code review antipatterns](https://www.chiark.greenend.org.uk/~sgtatham/quasiblog/code-review-antipatterns/)

An excellent bit of sarcasm. Well worth the read, especially for new engineers
(what not to do) and experienced engineers (who laugh because of their
experience).

## [git-random](https://git-random.olets.dev)

A tool I've been meaning to build (roughly), and it already exists! I actually
want to be able to draw a graph shape and have the tool create it, but this is
close and might serve as a back-end.

## [Why GitHub actually won](https://blog.gitbutler.com/why-github-actually-won/)

Much to [my chagrin]({% link _posts/2024-08-02-github-squash.md %}), it is a
dominant force. GitLab is probably the closest competitor and, if I recall
correctly, remains closed-source.

I'm strongly [considering
alternatives](https://sfconservancy.org/GiveUpGitHub/), and I think you should
too. [SourceHut](https://sr.ht) is the most compelling for me right now, but
it's nice to see that we still live with a [thriving Git forge ecosystem]({%
link _posts/2024-04-30-extracting-ourselves-from-github-equals-git.md %}) that
really puts its weight behind "decentralized."

## [My unorthodox, branchless git workflow](https://drewdevault.com/2020/04/06/My-weird-branchless-git-workflow.html)

While I'm jealous of the "rebase all work at once" aspect of this flow, I'm not
sure I could handle organizing that much parallel work just in rebase todo lists
(partly because I work for a company that, at it's best, still has some review
and merge cycles that take longer than a few days).

It also wouldn't surprise me if keeping everything together made it easy to
accidentally send patches out that depend on previous patches without
remembering this fact or mentioning it, which could become very confusing.

## Notes

[^1]: To add a bit of nuance to this, I don't care what you do in your tree.
    Comment out code, play around, whatever. But in the canonical upstream tree,
    the main branch? Don't send me PRs with bodies of commented out code.
