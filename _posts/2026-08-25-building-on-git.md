---
title: Building on Git
tags: [ software-engineering, git ]
category: [ Blog ]
---

A conversation-via-blog with Dev Doshi about Git's role in the future of
software development.

I apologize in advance for excessive parentheticals (I do like
[Racket](https://racket-lang.org/), so perhaps this is expected).

Dev asked recently about my "ideal version-control system" and if I'm "actively
using or building it" (he having moved his personal projects away from Git).
Here's a summary of my initial reply:

I like building new things on old stuff. From my perspective Git pulls in ideas
for features from the "future" (_e.g._,
[Jujutsu](https://docs.jj-vcs.dev/latest/)-inspired
[git-history(1)](https://git-scm.com/docs/git-history)). I like what SourceHut
is doing in terms of email-driven workflows (building on old, reliable
technology).

I think, as with all things, the less-than-stellar areas of Git today are those
that have seen relatively little focus by contributors (_e.g._, worktrees and
notes). These features might be functional, but paid and volunteer contributors
are most motivated by features that impact their company (server-side hosting
for the typical employees at GitHub/GitLab/Gerrit/etc.) or personal workflows
(_e.g._, the `git-subtree(1)` utility is being revitalized by a passionate
contributor).

I think these were all underused until recently, and now we're going to have to
invest more in them. For worktrees in particular, see also [Git Rev News
#137](https://git.github.io/rev_news/2026/07/31/edition-137/) and my patch
series on `core.useNanosec`, which will help once I can land it.

I conceive of Git as a _durable_ technology: it can be continually evolved to
stay relevant, though that might require significant engineering, and old
versions ought to continue to function well into the future. Other comparable
(computer) technologies are email, plain text, and lisp-qua-idea. No wonder Git
plays so well with some of these!

Now, my [Feeling of Computing](https://feelingof.com/) friends have argued it's
time for these things to die---and I often nod along with them. How can that be?
I believe the best way to displace these limited technologies is to _augment_
them, to create ecosystems of tools and data that support the "old" way of
working while ushering in new development. I don't think the network effects of
a total revolution in these areas will sustain interest (which sustains
development).

A harmonizing note, and perhaps my melody: to throw away Git for something else
is also to reject, at least partially, the community of contributors that have
made Git what it is. Put more softly, to revolutionize Git at scale you'd need
to bring along a large, distributed community with vast experience working on
version control. We'd still have to give up the indisputable value of what
brought us here.

That sounds an awful lot like the sunk-cost fallacy.

I claim the cost is not sunk: Git powers a dominant portion of version control
and software collaboration today. It could use more diverse networks ([breaking
the GitHub monopoly](https://sfconservancy.org/GiveUpGitHub/)), certainly, but
network effects demand interoperability, collaboratively or adversarially. Hence
_augment_ rather than _replace_.

Further, any new revolution in this space would need to replicate the power of
the community surrounding Git, which goes beyond the core mailing list
contributors. Learning that my impact is larger in collaboration with a team was
critical for my success at Capital One, and I think the same is true of open
source: we achieve more together than by siloing off our innovation.

(I'm all for [situated software]({% link _posts/2025-04-18-skepticism.md %}#situated).
Version control underlies software development, though, and I fear that deeply
segregated software networks---such as those formed by each inventing our own
bespoke system---make contribution difficult and will either (a) re-invent Git
as "diff + email" or (b) stifle open source software communities
from forming. We need version control that encourages working in the commons.)

My current finger on the pulse suggests 2 things:

- Git embraces innovation driven by competitors.
- Competitors are fragmented, each bring sometimes-orthogonal and
  sometimes-overlapping innovation.

I consequently prefer to stick with and contribute to Git until a consensus
emerges among competitors. Git serves me well and could become that consensus
with care.

## Philosophy aside

Dev raised some interesting areas that need further work or aren't well
supported, saying this makes him feel like Git is not the right foundation. His
sense is that backwards compatibility enjoinders fixing many of these areas.

I asked for folks like Dev to tell the Git community about the limitations and
implicitly to contribute to fixing them :wink:.

I also said that I am seeing more willingness to throw away historic baggage if
well-justified (cf. 3.0 Breaking Changes document, removal of `git whatchanged`,
etc.).

This will definitely require continued culture shift over time, too! I think
it’s possible to build on the stellar community without having to reinvent
everything.

It’s also an open protocol, so you can build your own client or VCS on top of
it.

So, here's the list of things Dev said were limits of points of friction, one at
a time with replies.

> - giving a freelancer granular access to some part of a repo without being able
  to read another part. CODEOWNERS exists but it's limited and it's a
  github/gitlab thing not a git thing
> - having a private repo that has some public repo parts, and managing changes
> - there's no concept of layers. for example a layer that applies some debugging
  lines and such, environment files, whatever. stashes are close but not quite
> - architectural impedance mismatches; not designed to be composed, not designed
  for agents (especially worktrees/"forking". I hear you on that being possible
  to improve)

It's certainly true that Git doesn't support slicing repositories well. The
state of the art for Git is
[git-filter-repo](https://github.com/newren/git-filter-repo) and
[git-subtree](https://manpages.debian.org/testing/git-man/git-subtree.1.en.html),
or submodules. I use submodules for my Dotfiles and like them, but there are
plenty of rough edges when collaborating. I've used the subtree merge strategy
from both usptream to downstream (the latter has the former in a subdirectory)
and from downstream to upstream (picking changes back upstream) when working
on Dracula Pro's Vim theme, and it's smooth but requires advanced knowledge or a
competent integrator.

Another option is a branch that you merge into your current work for debugging,
etc. The workflow is not great there, either, but can be made to work with
interactive rebase. Use `--autosquash --update-refs --rebase-merges` or similar
with `commit --fixup`, etc., to change patches before the merge, and rebase the
merge away when preparing for final integration. I once worked on ~5 branches at
once with a mega-merge and this kind of workflow, based on [Steve Klabnik's "all
branches at once" paradigm from
Jujutsu](https://steveklabnik.github.io/jujutsu-tutorial/advanced/simultaneous-edits.html),
and lately it reminds me of [GitButler](https://gitbutler.com/)'s parallel
branches (the Desktop demo is best there).

If you could split a repo nicely, an integrator responsible for accepting the
freelancer's patches could also rewrite them to apply to the non-split repo
where that was necessary (possibly with help from Git). That's policy-driven
more than mechanism-driven, though.

In contrast, [Beagle](https://replicated.wiki/) supports
[overlays](https://replicated.wiki/blog/partI.html). I could imagine an overlay
implementation using multiple Git indices, but it would need a lot of work for a
smooth user experience. Overlaying a public repo into a private one trivializes
the second bullet, I think, but as I said it needs implementation.

On the other hand, I've never needed to give someone access to only part of a
codebase. That permission model doesn't exist in Git; if you can talk a host of
some kind and read the repository (even just `file://`- or SSH- URLs), then you
can get and recreate everything. So that needs something beyond the ability to
combine repos like overlays; you need a pragmatic "split" operation.

Demands of this kind are arguably signals that our code is not ideally
structured for the needs we have. I am sympathetic, though: I detest adapting my
work to a tool rather than the tool adapting to my work.

> - overall composability as a distributed system. an api sdk generation company
  wanted me to implement an sdk release workflow using release-please on github
  actions. There are some race conditions that are basically impossible to deal
  with by design

I'm not entirely sure I understand what the issues are here, and I've used
release-please (in anger).

One thing that comes to mind is workflows that trigger on tag pushes (say, to
create a release). Tags are mutable, so one could kick off a job but later
change the tag in such a way that something bad happens?

If memory serves, though, release-please likes to manage tags itself.

It is true that the Git ecosystem is _fragmented_ in the sense that composition
requires knowledge of 3rd-party tools and how to obtain them. I'm loathe to
suggest a "package manager for Git extensions," but… Anyway, I've also seen
plenty of half-baked Git integrations that make unfounded assumptions and break
with even slight deviations from the tutorialized workflows (_e.g._, it's common
to assume the only workflow is `push.default=simple` and `@{upstream}` points to
the place you push).

> - large files are annoying to deal with. you'd imagine a natural fit between
  artifacts from ci/cd being associated with the commits they came from plus the
  run they came from.
> - typically I have a versioned artifact model so code is versioned alongside
  artifacts and code refers to versioned artifacts (directly or indirectly) like
  darklang, unisonlang, etc.

Yep. Git-LFS is still hanging on, but changes to the object database ("odb")
subsystem are building towards _pluggable odbs_. That means you can natively
plug in storage of your choice for Git objects---S3, Postgres, whatever. I sent
a similar note to Andrew Nesbitt after he wrote about [Git in
Postgres](https://nesbitt.io/2026/02/26/git-in-postgres.html). NVIDIA is also
running a hackathon to work on a Git-LFS replacement after this fall's Gerrit
User Summit.

The CI/CD artifact association is, I think, better handled by something like Git
notes, but we have a long way to go at making users aware of them, integrating
them with popular forges (GitHub _removed_ support for displaying notes, but
still receives and sends them with pushes/fetches), and making notes management
facile. It's easy to end overwrite notes you didn't intend to today, since most
tutorials on synchronizing notes recommend a forceful refspec
`+refs/notes/*:refs/notes/*`. If you omit the `+`, you then might have to deal
with failed fetches by manually reconciling notes (`git fetch … && git notes
merge`).

I also wish I could expose folks to [Beagle's
links](https://replicated.live/blog/link) (cf. [Wiki is Not
Enough](https://replicated.live/blog/wiki)). I have similar facilities baked
into Vim with Fugitive, which makes navigating Git history a breeze.

> - committing itself is kind of weird if you think about it. or at least the way
  most people commit. I commit just as checkpoints of code, without them
  reflecting any statement about buildability, releasability, deployability etc.
  but coding agents

I'm not sure what agents do differently, but my hope (see [Git Office Hours]({%
link _workshops/git-office-hours.md %}) and [Theory Building with Git]({% link
_posts/2026-08-16-theory-building.md %}) for just a _taste_) is actually that we
train more human programmers to use commits as a meaningful state of the world.

That is, I like the "local can be meaningless checkpoints as long as what I send
for review has semantic weight." Git's own code review enforces this and creates
a much more meaningful history as a result.

Trunk-based development and a philosophy I can no longer find that I associate
with some notion of "monotonic commits" (the system wouldn't commit if tests
didn't pass, or something) have similar thoughts: check-ins should be buildable
and releasable at any moment (aided by modern notions that "deployed does not
imply released" in industry, perhaps).

> - things like ordered ADRs or changesets.dev (possibly more of a statement about
  file systems not having the concept of a list or collection or array where you
  can just dump stuff in without caring about names)

I'm not sure what Dev is missing here, but a directory with numbered files might
work (or a single large file, heh…).

Anyway, I've seen plenty of folks store changeset- or ADR- related content in
Git. I think the invention of changesets as a response to "handling merge
constant conflicts in a shared CHANGELOG file" does reveal a real pain point
though.

> - based on diffing text not structured data (see lix.dev and other projects).

Sure. Beagle uses [structured syntax-aware data](https://replicated.wiki/wiki/),
but I wonder about how that impacts durability as I previously defined it. I use
lots of languages, and I don't relish teaching Git about all of them.

On the other hand, [Linus's infamous rant about
renames](https://lore.kernel.org/git/Pine.LNX.4.58.0504150753440.7211@ppc970.osdl.org/)
applies: as long as work with the original form, we can always layer additional
smarts on top. That's how [defining a custom hunk
header](https://git-scm.com/docs/gitattributes#_defining_a_custom_hunk_header)
and related
[textconv](https://git-scm.com/docs/gitattributes#_performing_text_diffs_of_binary_files)
work: we can make smarter diffs. Smarter merges are possible with
[mergetools](https://git-scm.com/docs/git-mergetool).

It could be nice to integrate tree-sitter with Git for fallbacks on some of
these, though. The user experience of managing tree-sitter grammars is painful,
though, and has some interesting security implications if I understand the
situation correctly with respect to loading compiled grammars into process
memory.

> - git hooks (from an ergonomic and security perspective)

I've not seriously considered the security implications, but note that Git
accepts that its shell prompt may cause arbitrary execution in an untrusted
repo, so best practice is to be wary of untrusted repos. (I can't find the
reference I'm thinking of, but [this advisory looks
related](https://github.com/justinsteven/advisories/blob/main/2022_git_buried_bare_repos_and_fsmonitor_various_abuses.md),
as do the links in [a StackOverflow
post](https://stackoverflow.com/q/74200395/4400820).)


> - [https://www.linkedin.com/feed/update/urn:li:activity:7481394893186109440/](https://www.linkedin.com/feed/update/urn:li:activity:7481394893186109440/)
  (not sure if git or github, but fundamental performance issues)

Sounds like a mix of Git (no "patch theory", pushes are not "boring") and
high availability demands.

If we accept Git's distributed nature and don't require constant contact with a
server, maybe we can sacrifice high availability. That might require giving up
GitHub :wink:.

This is separate from the so-called ["crime against software" performance
issues](https://eblog.fly.dev/githubbad.html), related to the [Missing GitHub
Status page](https://mrshu.github.io/github-statuses/).

> - most file systems are fundamentally inefficient with git repos / lots of small
  files, most OSs don't usually handle them well. in contrast, I have a simple
  append-only log with OCC and a content addressed store. with that I can build
  pretty much anything, it works in memory as a library easily, I can fork
  extremely cheaply, and usually don't pay file system taxes until I absolutely
  need to (is it fair to say disks are possibly 10k x slower than memory?)
> - fwiw I think some of the issues are because of the POSIX file system model
  which I don't like either
> - [https://rcrowley.org/2010/01/06/things-unix-can-do-atomically.html](https://rcrowley.org/2010/01/06/things-unix-can-do-atomically.html)

Since I don't have much experience with filesystems suffering like this, I can't
speak to this well.

Git does have the ability to build in-memory indices and objects, though, and
(see next) libifying Git to allow other programs to take advantage of this is an
ongoing effort. Recently, git-history and
[git-replay](https://git-scm.com/docs/git-replay) use this to their advantage
for performance.

> - so maybe I'm proposing more of an unbundling refactoring of git

Yep, making `libgit` (the library built from Git sources that its builtins link
to, possibly statically?) useable is a long, noble, and active project. One of
the major current efforts is making more procedures independent of the global
`the_repository` instance so they can be used with any `struct repository`.

Anyway, long-term I hope that `libgit` will supplant `libgit2`, which isn't
actively developed as far as I know and has found it hard to replicate modern
Git features.

## Git At Any Scale

And of course the recent [Git At Any
Scale](https://cursor.com/blog/git-at-any-scale) article came up.

I think the article misses some points:

- Relying on a central server is anathema for Git. Maybe that's ok, and we can
  move on from that model? Open source communities in particular ought to reduce
  dependence on a single point of failure.
- The scalability problem is hard if you insist that all the parallel
  repositories stay synchronized (_i.e._, that they pretend to implement a
  single repository). If we were willing to accept temporary drift, I wonder if
  that could help? Few options need a truly synchronized view for a forge, I
  think. From what I can tell, this would require some further changes in Git,
  though, if write + read inconsistency confuses Git.
- If distributed hash tables were great, why not fix clones to not require the
  packfiles? Maybe that could still happen.

Still, they seem to have a clear-headed analysis for Git hosting "in the large."
Some specifics are tied to agents, which apparently create many small unused
repos? Unless those repos are on a forge, I'm not sure why the host is paying
for them, though. Some are tied to monorepos, which we know have tradeoffs for
their size. Though if the Linux kernel can make automated compilation farming
work, why can't everyone else use their job runner for CI tests with their large
monorepo? I confess I'm confused there. Maybe it's the number of
jobs---presumably the Linux kernel project only pays for CI on dedicated
branches and trees, while a company wants every PR to run CI all the time.

My suspicion, from observing a lot of small communities, is that the problems
here are only relevant from a certain industrial perspective. Plenty of Git
hosting in the _small_ is content with plain old HTTPS, static sites generated
from repos, or small instances of popular forge implementations.

And Continuity-style S3 object storage ought to be accessible to all via
pluggable odbs, though I regret that Continuity specifically seems tied to
Amazon. (Bring your own cloud?) Perhaps these folks will contribute to the Git
ecosystem and the pluggable odb work. I'm not sure I'll hold my breath.

## Wrapping up

I look forward to continued dialog with Dev :) If he posts any kind of reply to
this publicly, I'll link it here.
