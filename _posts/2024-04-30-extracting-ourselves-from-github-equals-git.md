---
title: 'Extracting Ourselves from GitHub = Git'
tags: [git, github, rants, open-source]
category: [ Blog ]
---

It's time to remind ourselves that GitHub and Git are not synonyms.

A word of caution: this may all seem like pedantry to you, dear developer, who
wants to write some code, get paid, and move on. That's fine. Software
development is for many just a job. What makes this pedantry worthwhile is the
essence of dictionaries: speaking a common language enables more effective
communication. Communication is critical to productivity.

I thus invite you to think of this article as an introductory language crash
course. "Git & GitHub 101," if you will.

## A Brief History Lesson

Git was first released in April 2005 with commit [e83c516331 (Initial revision
of "git", the information manager from hell,
2005-04-07)](https://github.com/git/git/commit/e83c516331). Version 1.0 followed
by the end of that same year.

I won't recount the history of Git's invention here. There are plenty of other
places for that:
- [https://en.wikipedia.org/wiki/Git#History](https://en.wikipedia.org/wiki/Git#History)
- [https://www.linuxjournal.com/content/git-origin-story](https://www.linuxjournal.com/content/git-origin-story)
- [Kernel SCM saga thread](https://lore.kernel.org/lkml/Pine.LNX.4.58.0504060800280.2215@ppc970.osdl.org/T/#u), with [the very first mention](https://lore.kernel.org/lkml/Pine.LNX.4.58.0504072127250.28951@ppc970.osdl.org/)

I will briefly mention that predecessors such as
[SCSS](https://en.wikipedia.org/wiki/Source_Code_Control_System) go back all the
way to the 1960s and 70s, and the design of SCSS,
[RCS](https://en.wikipedia.org/wiki/Revision_Control_System),
[CVS](https://en.wikipedia.org/wiki/Concurrent_Versions_System), and [Apache
Subversion](https://en.wikipedia.org/wiki/Apache_Subversion) played a role in
shaping Git and its peers[^1]. See also [a brief history of version
control](https://en.wikipedia.org/wiki/Version_control#History).

Finally, GitHub didn't emerge until 2008. It, too was shaped by its peers,
notably such [forges](https://en.wikipedia.org/wiki/Forge_(software)) as
[SourceForge](https://en.wikipedia.org/wiki/SourceForge).

The differences between a forge and a version control system are the primary
concern of this article, using Git and GitHub as the exemplaries. That we
categorize Git and GitHub differently should make it clear they are distinct
entities.

## Common Mistakes

This section covers some of the most common mistakes I see working with
developers every day, roughly in order of commonality and importance.

- Git is not GitHub. This is the point of the whole article: don't say one when
you mean the other. If you're not sure which you mean, find out if it exists as
a major concept in the [documentation for Git](https://git-scm.com/doc); that's
usually a good [razor](https://en.wikipedia.org/wiki/Philosophical_razor) to
separate one from the other.
- There is no such thing as a "Git issue." GitHub has
[Issues](https://docs.github.com/en/issues), and many other forges have
bug-tracking features. Some projects even use tools outside of software forges
to track bugs. _Bug tracking is not a Git feature or principle: Git is for
version control._
- Corollary: GitHub issue references are not permanent. Referring to `#1234` in
a commit or elsewhere may conveniently create a link in GitHub, but if you ever
switch systems that won't be helpful. I thus advise using the full link
`https://github.com/<org>/<project>/issue/1234` _and_ including the relevant
context with the link.
- Git has no notion of pull requests. This one is, admittedly, an easy mistake
to make: Git has a command called
[`request-pull`](https://git-scm.com/docs/git-request-pull) to "Generate a
request asking your upstream project to pull changes into their tree." That is
essentially what a GitHub Pull Request is: a request for one repository to pull
changes from another repository's accessible branch. On GitHub, a PR is forced
to specify a destination branch, too, but in distributed workflows it may be
that multiple upstream branches should pull from the source branch.
- GitHub is not Git. I already said this, but let's take a different angle: I
think GitHub's enormous market share confuses people. There are actually _many_
different ways to host Git repositories so that they are accessible for
development, open-source or otherwise. For example, [Pro Git describes some
aspects of hosting a Git
server](https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols), in
addition to the builtin visualizer
[GitWeb](https://git-scm.com/book/en/v2/Git-on-the-Server-GitWeb), the GitHub
competitor [GitLab](https://git-scm.com/book/en/v2/Git-on-the-Server-GitLab),
and other [third-party
options](https://git-scm.com/book/en/v2/Git-on-the-Server-Third-Party-Hosted-Options)
like [Gitea](https://about.gitea.com) and [SourceHut](https://sourcehut.org).
Some projects, including Git, do most development on mailing lists and don't use
most of the major forge features. Many of the options mentioned here are
open-source themselves and can also be self-hosted.

## Forks and Branches

I see many, many developers confuse these two terms, and I'm going to attempt
the impossible: to disambiguate them. I suspect that most of the confusion is
due to age: many of my peers didn't experience the history that gives these
terms such specific meanings, and most don't read the documentation or historic
notes that explain them. So, for your benefit, dear reader, I've done what
research I need to extricate these terms and point you towards more details.
Here are the fruits of that labor (roughly in order of importance?).

Most importantly: Forks and branches are entirely orthogonal concepts. A
[branch](https://git-scm.com/docs/gitglossary#Documentation/gitglossary.txt-aiddefbranchabranch)
is a kind of
[reference](https://git-scm.com/docs/gitglossary#Documentation/gitglossary.txt-aiddefrefaref),
also called a `ref` in Git's documentation. Git's documentation actually
considers a branch an entire history of commits; in practice, we typically mean
the reference `my-feature` when we talk about the branch `my-feature`, not the
list of commits produced by `git rev-list my-feature`.

A fork… well, here's where it gets tricky. I'm going to walk you through a
useful set of working definitions, then tease apart some history and nuance.

### Different Kinds of Forks

**Update 2025 February 2nd**: What I call "forks, Forks, and divergent forks"
below, [Drew DeVault calls "trees, Forks, and
forks"](https://drewdevault.com/2019/05/24/What-is-a-fork.html)[^4]. This is
much closer to the historically used terminology, and I've started using "tree"
and "fork" interchangeably. DeVault also wonderfully explains how all these
forks---trees---are part of what make Git distributed and why GitHub co-opted
the meaning. I highly recommend his article.

I'm going to distinguish 3 kinds of forks: forks, Forks, and divergent forks.

- A fork is a URL[^2] that points to a related[^3] repository. In a non-bare
local fork, we typically keep track of other forks as remotes. Notice that I've
referred to a "local fork": a clone is "just another fork."
- A Fork is a [GitHub
feature](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks)
for making contributions easier (more on this later). GitHub says a Fork is "a
new repository that shares code" with the "upstream" repository. This is close
to what a fork is, actually, and most Forks are useful forks, too. A few
clarifications are in order. First, GitHub said the Fork and its upstream
repository share code, but actually they share a common commit history. Second,
GitHub relegates Forks to 2nd-class status by not enabling certain other
features in its UI or otherwise for Forks.
- A divergent fork is my term for distinguishing forks that take a social stance
on what repository is considered canonical. More on this later, but if you're
thinking "OpenTofu forked Terraform," I'd call that a "divergent fork" in this
article. In practice, the open source community just calls these forks, and I
need the "divergent" label only to usefully distinguish these kinds of forks for
this article.

To recap: every copy of a repository is a fork. GitHub provides a way to create
special forks for contribution via their platform that I call Forks. Some
projects diverge meaningfully from a shared history, and these are also called
forks.

The distinction between a fork and a divergent fork is that one is technical and
the other is social. We'll cover the social area later.

### History of the Term "fork"

[The word "fork" goes back to at least 1980][fork_history]. Over time, it has
been used for a variety of purposes, including things that are closer to what
Git calls a branch or repository. In the Jargon File, it is explicitly about
divergent forks (with a serious negative connotation): historically, divergent
forks were seen as fragmenting the ecosystem, which was A Bad Thing™. In modern
open source development, the proliferation and competition of related ideas and
works via distributed development is widely considered a good thing, and
divergent forks are generally not frowned upon unless they are antagonistic.

It is telling that the only mentions of the word "fork" in Git's documentation
are in documents describing GitHub interactions: there is nothing technically
inherent about the concept of forks (or Forks) in Git's design. This is part of
what makes Git distributed: all that matters is copies of the commit history and
how to refer to them.

### Contributing to a Project: forks and branches

There are two kinds of contributions: those for yourself and those for others.

A contribution for yourself (where license permits) only requires a copy of the
source code (and typically its history). That is, you need a fork. Then you edit
the code. Committing is not even strictly necessary.

To share that contribution with others, you need to either
- Make a branch of history available somewhere that other interested parties can
pull from
- Send others a patch series, such as from `git format-patch`

In the end, you are taking your work and sending it to others with a request
that they pull from your line of work. A Fork is a convenient place to make
branches available to others, and that is what makes GitHub Forks a useful
feature for contributing to projects. But you still want a line of commit
history somewhere; this typically resides in a branch.

### The Social Aspect

Git treats all forks the same: they are equally unprivileged. Only social
processes privilege some forks as canonical over others.

For example, it is widely agreed that Torvalds's Linux kernel repository is
canonical. There is nothing in Git that enforces this, only social convention!
Similar arguments apply to the GitHub mirrors git/git and gitster/git, along
with the divergent fork microsoft/git.

Following this to its conclusion, when [OpenTofu.org](https://opentofu.org) says

> Open Tofu is a fork of Terraform

what they roughly mean is

> We have a Git repository that contains some shared history with the canonical
> Terraform repository. We have technical differences A,B,C and social
> differences X,Y,Z; these make us interesting because of MN and you should
> consider using our project.

They might or might not mean they want to supplant an existing canonical
repository as dominant via social process; that is, they _may_ intend to become
the defacto hub for Terraform-like software, but the primary message conveyed is
one of commit history and technical features.

Most Forks and forks have a similar message: "I have something interesting you
should look at. It's better than other repositories with shared history because
A, so you should use it, too." A request to other maintainers of other
repositories (forks) to pull in those changes (GitHub: a PR) is a way of saying
"You should pull changes from my fork because they will improve yours." That is,
_collaboration is all social._ The technical bits of Git support this kind of
collaboration because they were designed to for Linux kernel development, but
they serve other kinds of social contribution models, too.

Sometimes forks maintain parallel development with each having different
features. Vim and neovim can be viewed this way. Another example is
microsoft/git, which contributed the `scalar` tool back to git/git but still has
other microsoft-specific changes. It continues to integrate upstream git/git
changes to maintain feature parity. Packaging software, such as for a Linux
distribution, is similar because of patching: patches might add
platform-specific changes but try to maintain feature parity with the original
code base.

This is all part of what makes Git distributed.

## Recap

In a nutshell, there's a lot of Git and GitHub that work together, but they are
fundamentally separate objects. Git is primarily a technical tool for
distributed version control; GitHub facilitates some of the social parts of
collaborating on software, but is not the only way to do so. Keeping these
concerns separate allows us to better untangle the nature of forks and branches.
It might seem pedantic, yet sharing common language and understanding helps us
develop better software, together.

#### Footnotes

[^1]: Didn't you know? There's a whole [family of distributed version control
    systems](https://en.wikipedia.org/wiki/List_of_version-control_software#Distributed_model).
    There's even work on new systems being done today.

[^2]: Any kind of remote can be a fork, really, including other clones over
    different storage systems, local or otherwise.

[^3]: It's not strictly necessary for the histories to be related at the
    commit-graph level: `git merge` accepts `--allow-unrelated-histories` for a
    reason. Read related in a social, "this is relevant to me" sense.

[^4]: Well, he doesn't capitalize "Fork" when referring to GitHub, but I will to
    make it visually distinct.

[fork_history]: https://en.wikipedia.org/wiki/Fork_(software_development)
