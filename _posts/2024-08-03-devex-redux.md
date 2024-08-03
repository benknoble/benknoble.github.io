---
title: 'Developer Experience, Redux'
tags: [ developer experience, acm ]
category: [ Blog ]
---

I pull excerpts from recent _Communications of the ACM_ articles relevant to
developer experience advocates and add my own commentary.

## Resistance is your friend

Our first article[^1] is an opinion piece on the nature of resistance to change.
Denning and Lyons argue that human communities prefer equilibrium to disruption
and present a framework for using that resistance to build a better case for
your new idea, disruption, or innovation. In particular, they note that only
changes in a communities otherwise-satisfied concerns will open the community to
a new equilibrium:

> An innovation leader proposing a change of practice needs to understand and
> address those concerns. Rather than run away from the resistance or trying to
> overcome it by force, leaders move toward the resistance with curiosity and
> humility to understand why people are committed to the current equilibrium.
> The goal is discover latent concerns, which when brought to their awareness
> will motivate people to move toward the proposed change. You will not find a
> cause for the resistance by looking at external circumstances. You will find
> its causes in the everyday conversations of people in the community.

They write that their experience demonstrates that the best leaders "bend" with
resistance:

> Flow with the resistance, seeking to understand the concerns behind it and
> revising offers to take care of those concerns. Mobilize followers to build
> social power behind your offers and neutralize the social power of the
> resistance.

What does this tell us about developer experience? Developer tools cannot be
imposed by fiat or mandate: you risk a resistance movement that outlives any
particular persons ability to declare "the way." Worse, you don't have the
support of the community. There may be a period of perceived success, but it
usually eventually crumbles.

Instead, developer tools are best created by motivating the community, listening
to their problems, and solving them together. This allows you to mobilize
excited early adopters to pave the way for majority adopters.

## DevEx in Action

Our next article[^2] is a study of "developer experience and its tangible
impact." My one critique is that the article doesn't seem to consider team
turnover and the possible impacts to developer experience there: experience
suffers when picking up a project whose authors are no longer around regardless
of the state of anything else, but certain practices make this easier than
others.

This article uses surveys and statistical techniques to examine a proposed model
of developer experience concerns and relate improvements in developer experience
to tangible individual, team, and organizational outcomes. The statistical
connection provides powerful motivation for business to improve developer
experience:

> Now that you are sold on improving DevEx, how can you convince your
> organization to buy in? First, have them read this article. Then, joke aside,
> here are five important steps that can help you advocate for continuous
> improvements by keeping your arguments grounded in data.

The proposed model incorporates flow state, feedback loops, and cognitive load
as the concerns of developer experience. Studied individual factors include
learning, job performance, and creativity. Team factors include code
quality and technical debt. Organizational factors include retention and
profitability. The statistical findings indicate that, for their sample, flow
state and cognitive load positively impacts all outcomes. Feedback loops
influence team outcomes but not individual or organizational outcomes (see the
article for full details).

Here are a few topics I want to highlight.

### Git

As many of my <a href="/tags#capital+one" class="tag">Capital One</a> coworkers
know, I have spent a lot of time talking about the many ways in which <a
href="/tags#git" class="tag">Git</a> can improve developer experience if only we
spent the time to take advantage of our tools.

Speed and quality of information ("How often it takes >10min to have a question
answered") is an important aspect of the article's conception of feedback loops;
this is supported by prior research. I have long argued that Git as a version
control system tracks _by default_ the who, what, when, and where. Arguably the
how can be captured as well when the patches include mechanisms. The only person
who can answer _why_ is the commit author: take the time to write down why the
changes are necessary or important! Then Git becomes the ultimate speedy
answerer: search techniques from code search with `git grep` to sophisticated
history searches with `git log` and `-G`, `-S`, or `--grep` empower us to find
more information or more threads to tug on from the comfort of our workstation
and development environments. Even `git blame` has a role to play in helping us
understand our work. The authors write:

> Teams that provide fast responses to developers’ questions report 50% less
> technical debt than teams whose responses are slow. It pays to document
> repeated developer questions and/or put tooling in place so developers can
> easily and quickly navigate to the response they need and integrate good
> coding practices and solutions as they write their code, which creates less
> technical debt.

Certainly version control is not the only place for such Q&A documentation, but
it should be treated as the wealth of information that it is. This also suggests
that how to find answers to questions is a major (and trainable) skill.

Git shines not only in feedback loops: Git helps offload cognitive burdens, too.
We know that the human brain tends to hold on to incomplete tasks and create
stress while it is able to quickly erase completed tasks and associated stress.
Writing down our thoughts in a commit message is a form of completing the task,
relieving stress. It further enables us to search, not sort, our information:
sorting information is a maintenance intensive burden that doesn't always lead
to the information being easy to find. Commit messages offload our thoughts into
a kind of searchable exobrain that we share with our teams and our future
colleagues, whether we're around to work with them or not. Finally, commit
messages assist developers who want to understand code, which is an important
factor in the article's consideration of cognitive load.

### Impact

I'm not sure much else needs said here:

> To improve developer outcomes, deep work and engaging work have the biggest
> potential impact. To improve organizational outcomes, several items have the
> potential for big impact: deep work, engaging work, intuitive processes, and
> intuitive developer tools

By the way, the opposite also holds true:

> Developers who find their tools and work processes intuitive and easy to use
> feel they are 50% more innovative compared with those with opaque or
> hard-to-understand processes. Unintuitive tools and processes can be both a
> time sink and a source of frustration—in either case, a severe hindrance to
> individuals’ and teams’ creativity.

Since I have otherwise less to say about a third article[^3], I'll quote its
knowledge of automation processes such as CI (see original for citations):

> However, an immature automation process can result in negative outcomes, such
> as cost and schedule overruns, slow feedback loops, and delayed releases.

"DevEx in Action" presents a framework for making an impact consists of 5 steps,
which I'll summarize here:

> 1. Get data on the current developer experience.
> 1. Set goals based on your DevEx data.
> 1. Set your team up for success.
> 1. Share progress and validate investments.
> 1. Repeat the process.

Coupled with the previous article's direction on resistance, this provides a
powerful roadmap from which to iterate and improve outcomes.

[^1]: [Peter Denning and Todd Lyons. 2024. Resistance Is Your Friend. _Commun.
    ACM 67_, 6 (June 2024), 26–29.
    https://doi.org/10.1145/3654696](https://cacm.acm.org/opinion/resistance-is-your-friend/)

[^2]: [Nicole Forsgren, Eirini Kalliamvakou, Abi Noda, Michaela Greiler, Brian
    Houck, and Margaret-Anne Storey. 2024. DevEx in Action. _Commun. ACM 67_, 6
    (June 2024), 42–51.
    https://doi.org/10.1145/3643140](https://cacm.acm.org/practice/devex-in-action/)

[^3]: [Liang Yu, Emil Alégroth, Panagiota Chatzipetrou, and Tony Gorschek. 2024.
    A Roadmap for Using Continuous Integration Environments. Commun. ACM 67, 6
    (June 2024), 82–90.
    https://doi.org/10.1145/3631519](https://cacm.acm.org/research/a-roadmap-for-using-continuous-integration-environments/)
