---
title: 'Perspective on software development models'
tags: [git]
category: [ Blog ]
---

If I believe [simple questions have complex answers]({% link pages/about.md
%}#me), then it's no surprise that I have a complicated take on the following
question: branch-based or trunk-based development? Which is better, and why?

As usual, though, _we're asking the wrong questions._ For spoilers, jump to the
[conclusion](#conclusion).

## Impetus: opinion and advantage without mechanism or goal

Part of this post is a reply to posts like [Trisha Gee's "Why I prefer
trunk-based
development"](https://trishagee.com/2023/05/29/why-i-prefer-trunk-based-development/).
If you don't care for musings on that, skip to [the beginning of my
analysis](#analysis) for the rest of the post, which examines the tradeoffs of
branch-based and trunk-based development in light of 5 pillars.

Gee outshines many of her peers with her titular framing: the article explores
_her_ preferences based on _her_ experience. Too many answers to the question
of "to branch or not to branch" want to convince you of their absolute
correctness, shades of gray be damned. And if that kind of extreme conviction
sets off your spidey senses, it's time to double-check: are the authors of such
answers trying to sell you something?

Others repeat tired claims, often without evidence. This is cargo-cult
programming and should be approached with the same skepticism: ["Best Practice"
is not a reason to do something](https://chelseatroy.com/2022/04/18/best-practice-is-not-a-reason-to-do-something/).

Gee stands out, then, for speaking personally and from professional experience.
Her introduction winds you up for a "when I was at X and we did Y, we found Z"
tale. These stories form the basis of mature programmer thinking: I learn from
your experience and can better judge appropriate tradeoffs thanks to your lived
and earned wisdom. **From Gee's analysis of tradeoffs, I hoped to learn and to
be better equipped to analyze my own.** The results might be measurable or gut
feelings, and we would learn from both.

The main article falls flat.

Teed up for story time, we find instead a collection of opinion presented as
fact. This being the internet, of course we find opinion: there must be memories
that inform Gee's opinions (or else we are reading another cargo-cult piece, and
I want to assume positive intent of Gee, whom I don't know). We can't extricate
our opinions from the experiences that shape us. Thus Gee speaks from experience
but shares none of it[^3]. For example, Gee claims

> Integrating small changes regularly into your code is usually less painful
> than a big merge at the end of a longer period of time.

This is probably true ("usually"), but comes with none of the analysis that lets
us discern when or why. We'll examine specific claims later; for now, we are
disappointed in yet another "this is the way" string of paragraphs.

What are we missing? We have a set of opinions which are presumably backed by
the author's experience and which provide, according to her, some advantage. We
lack

- the actual mechanism by which these opinions are practiced, and
- a set of goals or desires against which we can judge the tradeoffs of
  different approaches and their effects.

We don't seek analysis to ground our precious art in hard-to-find evidence[^4]
or to participate in [empiricism
washing](https://pluralistic.net/2024/10/29/hobbesian-slop/)[^2]; rather, we aim
to derive from shared opinions lessons we apply to our own situations. We
welcome opinion. For claims of advantage, we insist on analysis in order to
integrate that opinion.

There is other material about the mechanisms of branch- and trunk-based
workflows. [Pro Git even covers
some](https://git-scm.com/book/en/v2/Distributed-Git-Distributed-Workflows), as
does [`git help workflows`](https://git-scm.com/docs/gitworkflows). Still I want
to mix discussion of tradeoff with implementation mechanism: I find this
clarifies my thoughts.

<a id="analysis"></a>We'll take Gee's 5 points for trunk-based workflows and
distill both mechanism and tradeoff for branch- and trunk-based workflows. By
the end, you'll see how I view the wide world of Git use.

## Speed and Efficiency

Gee claims that trunk-based development means code is integrated more quickly
and more efficiently:

> This model allows for quicker integrations and fewer merge conflicts. […] It
> might seem fast to develop your fixes and improvements on a separate branch
> that isn't impacted by other developers' changes, but you still have to pay
> that cost at some point. Integrating small changes regularly into your code is
> usually less painful than a big merge at the end of a longer period of time.

Here "integrated" code is code that has been combined together to serve some
purpose. Typically it is independently developed code, often for disparate
features or fixes.

Because we lack mechanism, we're going to take trunk-based development's
mechanism to mean something like

```
while ! git push; do
    git pull --rebase
done
```

In other words, rebase your single shared branch locally until you are able to
win the push race---after all, if I push first, Git will reject your
non-fast-forward push. (You may merge instead of rebase, but that becomes messy
for no productive reason.)

What is branch-based development's equivalent workflow? It depends on your team:
the patterns I've seen are:
- On-demand: Don't integrate the upstream branch into the topic branch unless
  there are conflicts that need resolved or upstream features that the topic
  wants. Only then perform a rebase or merge, as desired. Many open-source
  projects frown on merging from upstream when it is avoidable: prefer to base
  your work on the code that it needs, meaning you will need to rebase if you
  need new work.
- Continuous: Integrate the upstream branch constantly, typically via merge. I
  see this when "Require branches to be up to date before merging" is enabled
  for a repository, and especially when the default (or only) merge strategy is
  [squashing]({% link _posts/2024-08-02-github-squash.md %}). In the corporate
  environments I've seen this in, pushing otherwise unnecessary merges which
  clutter the PR is fine since they will disappear anyway.

I personally keep to a middle-ground of rebasing on-demand, but more often than
"only when there are conflicts" would suggest: in centralized workflows, I try
to keep branches with PRs based on the latest main branch. In distributed
workflows, I'm less picky about updating until I start a new version of a
branch.

Let's assume both workflows follow good commit hygiene (small, focused, frequent
commits) aside from debatably-unnecessary merges. Now we can examine tradeoffs:

1. _All_ integrators have to deal with conflicts eventually.
1. Trunk-based developers and continuous branch integrators integrate code more
   often by nature of the way they operate.
1. Assuming trunk-based developers push as soon as they have a working commit
   and that they work in a team, they must have to pull frequently. If they
   don't, they push far more frequently than any of their teammates, who _do_
   have to pull frequently. This can be a source of friction. In solo mode, the
   push is never rejected, which makes this strategy especially appealing.
1. On-demand integrators typically have more commits to rebase or merge when
   integrating because of the frequency at which it happens, and we all agree
   that more commits means more probability of conflicts.
1. On the flip side, making PR review and merge high-priority in a branch-based
   workflow means few branches live long enough to deal with complex conflicts.
   This might balance out against frequent integrations if a PR is quickly
   merged ("near-trunk-based") without conflicts: on-demand saves some effort
   here.

## Greater Code Stability

Gee claims that trunk-based development

> encourages frequent commits, which leads to smaller and more manageable
> changes. […] In the branching model, large and infrequent merges can introduce
> bugs that are hard to identify and resolve due to the sheer size of the
> changes.

Gee argues that more commits (by proxy of "more time") lead to a higher chance
of conflicts, which I agree with above and for which I suggested a mitigation.
Then she constructs a <a id="strawman"></a>**strawman** version of the branching
model: to compare _well-run_ trunk-based development, we should also use
_well-run_ branch-based development, in which ready branches are frequently
reviewed and either merged or rejected[^1].

In a well-run branch model, buggy merges are infrequent. Said another way, a
trunk-based developer who hasn't pulled in a while and creates a large merge
will have the same problems.

> By frequently pulling in the other developers' changes, and frequently pushing
> small changes of working code, we know the codebase is stable and working.

This actually depends on stable testing, as Gee writes, and is **independent of
workflow.** In sum, code stability depends more on practices exterior to the
particular workflow than on branch vs. trunk, personal experience and observed
correlations notwithstanding.

## Enhanced Team Collaboration

Gee writes:

> If you're all working on your own branches, you are not collaborating. You are
> competing. To see who can get their code in fastest. To avoid being stomped on
> by someone else's code changes.

And yet, as the `while` loop demonstrates above, trunk-based developers might
stomp on each other, too. **This is independent of workflow.**

This is often a social problem rather than a technical one; that is, I need to
speak with my team about the areas we're working on and how to organize them.
Resolving that resolves many issues.

> If you're all working on the same branch, you tend to have a better awareness
> of the changes being made. This approach fosters greater team collaboration
> and knowledge sharing. In contrast, branching can create a siloed work
> environment where you're all working independently, leading to knowledge gaps
> within the team.

Conversely, if most of a small team reviews every PR, we still share knowledge.
And for large projects with many subsystems (such as the Rust compiler),
de-siloing knowledge happens via RFC and commit hygiene, not (necessarily) by
reading every pulled commit. **This problem is independent of workflow.**

A few actual tradeoffs that are workflow-relevant:

1. Distributed development teams, whether open source or private, may not be
   able to accept trunk-based contributions from community for security or
   stability reasons: giving the internet commit rights to your deployment
   branch is a bad idea. The Rhombus project is driven primarily by PRs but
   cannot for stability, give commit rights to everyone.
1. Conversely, small teams with no or few other collaborators can commit
   directly and reserve PR workflows for those few outside contributors. The
   main Racket repository looks like this (in spite of many external
   contributors), as do many other open source projects with active development
   communities who don't mind core devs committing directly.

## Improved Continuous Integration and Delivery (CI/CD) Practices

Gee claims trunk-based development helps CI/CD because

> Any failures there are seen and addressed promptly, reducing the risk of nasty
> failures. It's usually easy to track down which changes caused the problem. If
> the issue can't be fixed immediately, you can back [sic] the specific changes
> that caused it.

As may by now be clear, **this is independent of workflow.** Tools like `git
blame` and `git bisect` are essential to tracking changes, and CI on PRs can
catch them before they are integrated. A CI system would need to warn me loudly
that a push caused a failure for me to notice: with branch-based PRs, I am
frequently looking at the status checks on a GitHub page (for example). That
doesn't mean a trunk-based CI system couldn't be noisy! It's a matter of tooling
and choice, not inherent advantage.

> It's at merge (or rebase) time that you start to see any integration issues.
> All those tests you were running on your branch "in CI" were not testing any
> kind of integration at all.

This is certainly true and is one of the main arguments for "Require branches to
be up to date before merging." CI typically also runs on the main branch,
however.

I do have experience with continuous _deployment_ becoming confusing with branch
models: fundamentally it's a tooling failure, however, because we don't have
per-PR environments. So to test a deployed PR I might be stomping on some
other PR's dev or QA environment.

Heavily regulated environments (such as my current workplace) may not be able to
treat each push as a deployment to customers: instead, in some domains we have
to be careful about when we release even if we merge frequently. For our
internal customers, release on push often works fine.

## Reduced Technical Debt

Gee claims that "merge hell" contributes to technical debt, and I agree: it
creates temptation for quick resolution rather than careful design. All
technical debt is tradeoff, though, and we usually choose to accept some.

> you may […] accept suggestions from your IDE that resolve the merge but that
> you don't fully understand.

Not understanding code you produced via tool **is independent of workflow.**
Stop doing that. (Code review _may_ catch this problem but is not a failure-free
safety net. See the "swiss cheese" model of code review.)

> With trunk-based development, frequent merges and smaller changes make it
> easier to manage and reduce the build-up of technical debt.

Replace "trunk-based" with "branch-based": does the sentence still ring true? I
think so. **This problem is independent of workflow.** Our assumptions of commit
hygiene support the claim of independence.

## Conclusion

See if this sounds right to you:

> [Software development] requires a mindset, a culture, within the development
> team. You need to frequently merge in other developers' changes into your own
> code. You need to commit small changes, frequently, which requires you to only
> change small sections of the code and make incremental changes, something
> which can be a difficult habit to get used to. Pair programming, comprehensive
> automated testing, and maybe code reviews are key practices to helping all the
> team to adopt the same approach and culture.

Gee actually wrote these words about trunk-based development, yet I find they
apply equally to branch-based development! What happened? Presumptuously, I
suspect Gee spent time with branch-based teams that didn't observe this culture
of commit hygiene and time with trunk-based teams that did. That kind of
anecdata can taint our view of a workflow _even when most of the salient
problems are workflow-independent_, which [leads us to create strawmen out of
poor habits](#strawman).

I leave you with the following thoughts:
- After analysis, the major tradeoffs of either workflow are needed tooling,
  conflict resolution, and how to do code review. Most of the rest is a problem
  of software development and team culture than a problem of specific choice of
  workflow. So _pick what works for you_.
- Perhaps the true question we should be asking is: what are the tradeoffs of
  following or not following good commit hygiene? Most engineers have some
  intuition for these tradeoffs, yet we all find large variety in adherence to
  commit hygiene. My analysis in this article suggests that good commit hygiene
  undergirds most of the advantages Gee ascribes to trunk-based development.
  Maybe that's the real change we need to convince people to make?
- It _may_ be the case that trunk-based development acts as a stronger forcing
  function for well-tested code, commit hygiene, and all the rest. Gee makes
  some claims to this effect, and I cannot personally evaluate them. I have seen
  struggling branch-based teams who adopt better test and commit hygiene come to
  benefit---the poster children of good branch-based development would be Git,
  Vim, Rust, and similar projects. Which style is more likely to force what
  practices is a very different article and set of claims, though![^5]

<a id="postscript"></a>PS Gee later writes in comments:

> It all comes down to discipline, and the team. For me, I prefer to see
> IMMEDIATELY if there are any problems caused by any developer’s commit. I
> prefer people not to commit if the trunk is red. I prefer people to fix
> problems AS SOON as they occur, and if they cannot be fixed inside 5 minutes
> (say), back out that commit and fix it locally. I prefer to work on the same
> codebase as everyone else, and not some isolated branch, even if that branch
> is only a day old.

This is what I expected coming in: "my preference is X, but it all comes down to
good hygiene." I would still have preferred to see what "back out the commit"
means, though I assume it's some version of `git revert`. Even here, "as soon as
they occur" can still be "when PR tests catch the problem."

Another commenter writes "even if you only ever work on main you absolutely do
have a local branch that is separate from the remote branch," which is an
insightful perspective: with Git's model, even centralized workflows don't force
you to synchronize for every change. There is always more than one branch if you
have a remote.

PPS A future post will cover my own workflows in various setups and
situations---keep an eye on the RSS feed for that!

## Notes

[^1]: Rejected branches that need follow up work to become ready are treated as
    new versions even when they share commits; in other words, think
    email-driven "v1/2/3" workflows even when working with GitHub's UI and
    rebases. On GitHub, you might also close a PR and start a new one if the new
    work is significantly different from the old, whether you rebase or not.

[^2]: See also [Cory Doctorow's essay on Qualia](https://locusmag.com/2021/05/cory-doctorow-qualia/)

[^3]: See [the postscript](#postscript) for a shift: in the comments, we see
    more of Gee's thought process.

[^4]: Though evidence is certainly welcome to inform tradeoffs. See for example
    [performance comparisons]({% link
    _posts/2024-09-14-benchmarking-pict-equality-pt-2.md %}) or [What we know we
    don't know](https://www.hillelwayne.com/talks/ese/).

[^5]: Evaluating them has to be sensitive to seniority, too: if you only have
    senior engineers in your trunk pool and juniors in your branch pool, well,
    that's the correlation you measure. And I suspect that many of us that are
    in poor branch-based communities now are surrounded by juniors in corporate
    environments that don't reward well the teams who spend time on these
    considerations; when we move to a pod of seniors that have already adopted
    the baseline assumptions (commit hygiene, etc.), whether they choose
    trunk-based or branch-based development, the model surely shines.
