---
title: Reading notes on "Configuration Work"
tags: [ llm ]
category: [ Blog ]
---

My notes on [Configuration Work: Four Consequences of
LLMs*-in-use*](https://arxiv.org/pdf/2512.19189).

These notes will focus primarily on the research project and the result,
omitting the methodology. The methodology is worthy of its own study, but I've
got to draw a line somewhere.

This paper from the [Ecologies of LLM Practices
project](https://ecologiesofllm.medialab.sciencespo.fr) sets a different tone
from most papers on LLMs in the workforce: it explicitly takes an *in situ*
approach to examine how we workers integrate LLMs in our daily activities.

Their result is 4 major themes that build on each other:

1. *Discretization*: workers learn to break down tasks into units the machine
   can process and respond to.
1. *Cluttering*: workers discover "additional forms of work to make the machine
   do the job."
1. *Attunement*: workers situate the machine within existing ways working,
   including accounting for discretization and cluttering.
1. *Desaturation*: as a result of the prior 3 themes, workers find themselves
   doing more of the most boring, automatable tasks---in direct contrast to the
   promises of more time spent on engaging, valuable tasks.

In sum,

> LLMs do not seamlessly integrate into work practices. People must instead
> **make them work** through the practical labor required to turn a generic
> system into one useable in specific profession ecologies. [emphasis original]

As you read the paper, keep in mind that the authors note (at the end) that
their results are not exhaustive nor applicable to all workers: they are
descriptive rather than prescriptive.

## Impact or consequence

Alcaras and Ricci open the paper with their choice of a *consequence* study. My
take on their motivation is that the limits of, say, the task model of work are
the limits of the current scientific discourse on LLMs (with apologies to
Wittgenstein). That is, research and discourse is so concerned with
productivity, efficiency, and a particular model of *work* (not *worker*) that
it omits useful and important detail.

I see a reflection of Felienne Hermans's _Computer Science Off Course_ podcast.
CS education largely ignores psychology, sociology, biology, history, literature
and practically all other fields outside of some forms of mathematics or
physics. As a result, we concern ourselves with what is easy and good for the
machine rather than what is easy and good for the human.

In particular, the "task model risks being performative" which makes its
"abstractions a reality"---it creates a self-fulfilling model where we emphasize
the machine, even twisting knowledge production to meet its criteria rather than
our own. This performance thus also risks becoming a "dominant perspective in
public policy, debate, and research." Whereas, in my and the authors' views, we
should make sense of the boots on the ground to stay (*ahem*) grounded.

A consequence study "describe[s] situated processes," examines a "mutual shaping
of values and technology," and "remain[s] grounded in the present."

While reading, ask yourself: are the studies you know of impact studies or
consequence studies?

- I would class [Epistemic Diversity and Knowledge Collapse in Large Language
  Models](https://arxiv.org/abs/2510.04226v2) (previously linked in [Modelling
  language or controlling it?]({% link _posts/2026-05-07-machines-humans.md %}))
  as an impact study in this framework, but I'm not sure how I feel about that.
- [How LLMs Distort Our Written
  Language](https://sites.google.com/view/llmwritingdistortion/home) (previously
  linked in the same post) seems like a mix via it's human-user component, but
  it is still primarily focused on the outputs of the machine (or human--machine
  gestalt) over the user of the machine.
- The [2025 edition of the METR
  study](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/#motivation)
  reads like an impact study.
- The [Gates notes on a "turbulent AI
  era"](https://www.gatesnotes.com/work/make-ai-work-for-everyone/reader/a-turbulent-ai-era-and-critical-choices-to-make)
  focus on impact. Indeed, it makes speculative claims about "replacing human
  cognition" or "do[ing] physical labor as smoothly as any human" and explicitly
  states "many commentators underestimate the extent of the impact AI will
  have." Speculation is not grounded in the present, is not [solving today's
  problems]({% link _posts/2026-09-27-todays-problems.md %}).

As the authors note, studying LLMs is complex: the object keeps shifting because
market incentives encourage a "permanent state of beta." And don't we *users*
know it!

## A few other odds and ends from the introduction

Paraphrasing, the authors claim that "GenAI" adoption is bottom-up and
worker-led. My reaction is, of course, citation needed! At least my experience
is with organizations imposing top-down policies and encouraging use---it's
rather those of that abstain who are quiet about it.

Returning to "practical labor," making a generic system fit a specific purpose:
in some sense, this is what we programmers do with general-purpose languages. We
bend them to fit a specific purpose. Folks like Hermans also contest the term
"general purpose" languages, at least if I've understood them. The language is
only general for a certain subset of thinking and programming! It still narrows
our considerations to those of the machine rather than those of the human.

Indeed, isn't much of computing making generics fit specifics? Whether finding
and manipulating generic office software for a specific task or convincing an
email program to match my workflow, I take a general program and accomplish a
specific task. With LLMs, though, we are required to "bring them into the
situation, to shape their orientation, and to interpret whatever they produce."

We have citations for the AI industry trend to conceal the extent to which human
labor is necessary, even if they seem by now dated (2015 and 2017).

The "scripted artifact" jargon is over my head. But "repeatedly re-specifying
the machine" jives with what I hear from users [who find the monorail
conversational model
troubling](https://blog.glyph.im/2026/09/serious-ai-product.html). Users must
further "construct the conditions under which the system becomes relevant"---and
does this encourage us to change our work to be more LLM-friendly?
Discretization and desaturation seem to say: yes.

## Discretization

In the briefest terms, discretization is becoming the Jira backlog curator.

Folks in the study turned to LLMs for clearly defined tasks. The machine even
performed well on standardized tasks with precise rules. As we will see later,
this encourages doing more of those tasks, not less.

Some folks used LLMs for whatever it was "good at," all based on a variety of
sources to define that scope. Some even rejected coding as creative! (We'll
return to that in *Cluttering*.)

These folks came to realize that what may be a single smooth step to the human
was necessarily multiple discrete steps for the machine. We can speculate on
what creates these limitations (I hypothesize at least the context window, and
likely more---even with the latest research, systems in my experience struggle
with long time horizons), but the fact remains that limitations exist. Work that
relies on long continuity or long-term feedback is particularly difficult with
the machine.

This is perhaps expected: much of what makes me a reliable, productive colleague
is informal, tacit, or spread across multiple systems, and these things are
precisely the work that requires long continuity or long-term feedback. While I
use the machine to simplify or ease this work, I don't believe it will replace
this work. Process knowledge is tacit and not easily automatable. Think of what
you lose when you fire someone.

This section also contains discourse on where new tools usually fit within our
work. Historically, they adapt rather than radicalize: cinema, telephone, and
more reinforced existing social and institutional structures. (As for myself, I
think those structures need altered or replaced!) Some might say we bias towards
the status quo, which I see as a software engineer, too. What's already written
and working is better than a hypothetical.

The major difference, according to these authors, is that integration of LLMs
happens within the context of a single worker rather than between workers. It
happens *after* automation rather than as a pre-requisite. The worker decides
how to discretize rather than having discretization imposed by, _e.g._,
management.

All of this discretization requires noticeable effort. Indeed it reveals the
hidden skill, coordination, and intricacies of "mundane" work. For example,
attempts to automate roll-call revealed the value of that moment in
teacher--student relations. Or think of an open source contributor---a bot that
thanks your for time creates less lasting connection than a short note from the
maintainer.

See also [CSOC: Breaking things at work](https://www.felienne.nl/csoc-s01e08/)
for a recent treatment of historic discretization via Taylorism.

## Cluttering

Integrating new systems requires time and effort. For this study, it created new
forms of work which sometimes take time away from the actual job (as we have
said so often this week, "customer experience and impact").

Ideally, we'd fall into the classic [automation XKCD](https://xkcd.com/1205/):
time saved. But how does it feel? And *does* it save time? Indeed, another
[classic XKCD](https://xkcd.com/1319/) shows what often happens as we automate…

While discretization is concerned with existing work, cluttering is new
work, "new small practices that feel out of place, unnecessary, hard to
navigate." As the researchers put it, "prompting was a chore." No one enjoyed
using the LLMs, contrary to expectations, which included an "ideal candidate"
who still just wanted the machine to do the thing.

With prompting a task to skip (despite "prompt engineer" media buzz), the goal
became a "paste, enter, copy" cycle. Some tasks required more or more careful
prompts, though the vignette in the article stops short of answering which or
why.

Yet another additional task is evaluation: while the machine "sped up the act of
writing," it "multiplied the work of reading." This is consistent with my
experience as a code reviewer: evaluating LLM-generated PRs is exhausting and
rarely worth the effort I spend on it. The "vigilance required became
exhausting."

No surprises to anyone familiar with automation fatigue or blindness.

(See [Redundant Automation Monitoring: Four Eyes Don't See More Than Two, if Everyone Turns a Blind Eye](https://pubmed.ncbi.nlm.nih.gov/29939767/),
[Supervised AI isn't ](https://pluralistic.net/2023/08/23/automation-blindness/#humans-in-the-loop),
[Humans are not perfectly vigilant](https://pluralistic.net/2024/04/01/human-in-the-loop/).)

Using voices like those of typical professionals made errors harder to catch. No
wonder others think [1st-person voice shouldn't be allowed in the
tool](https://blog.glyph.im/2026/09/serious-ai-product.html). Work shifted, as
before, to tasks that are easier to evaluate:

- those with which workers have enough experience to easily judge the result
- those outside a workers experience that become good enough-able

If so much is outside typical CS education, will we unintentionally train
programmers not to care about these fields? We see the mirror in study
participants: "code either runs or it doesn't" is an attitude far removed from
the gradients of correctness modern programmers consider part of our work.

Participants also attempted to learn the relationships between input and output
so that they could get better results in the future. The machine is too
unpredictable, however, and became frustrating. Workers didn't have control over
their outcomes (for which they were spending extra time and effort). Thus they
stopped caring about prompts. Either they didn't understand the machine well
enough or it was too unreliable, in their conception.

What an interesting mirror to hold up: which do you believe? Is the machine to
sophisticated for these folks or too unreliable?

So, clutter. Prompting, evaluation, verbosity. LLMs are supposed to free us from
drudgery, but they create more of it…

Participants created strategies analogous to delegation called "decluttering";
they picked tasks with less inherent clutter, used "ritual" prompts believed to
lead to better outcomes, and mechanized evaluation of results. They also engaged
in boundary work, determining when and whether to use the LLM and when to
withdraw from it. Yet in spite of all that they could not escape constant
"automation suprises" because the system defies control and expectation. Thus
nobody forms an expertise in the system through which to better manipulate
outcomes!

This leaves us all with a feeling of unproductive labor. Effort does not
translate to result. Rather than a black box solution, we have a black hole
sucking up our investment of time, energy, resources, and yielding little in
return.

## Attunement

All the "adjustment of practices, expectations, and valuation to the machine's
perceived generic rigidity."

A mouthful! I think the idea is that generic capabilities are expert at nothing,
and attunement captures the adjustment we workers make to these rigid machines.
In some sense it appears to capture both discretization and cluttering. An
everything machine is really a nothing machine.

Participants' attunement meant they were no longer convinced the LLM can replace
them. They found it like talking to a novice, outsider, or alien rather than a
seasoned colleague. This metaphor unfortunately extends a "managerial class and
ideology," the same we see perpetrated all over late-stage capitalism. Yuck.

The LLM fails to adapt: unlike a human, it doesn't learn through context,
observation, or repetition. When a human makes a mistake, we learn and can be
taught. The LLM has to be told each and every time. The machine depends on
explicit instruction, while professional knowledge is often embodied, tacit, and
distributed.

This rigidity leads to discretization and cluttering, which eventually creates a
need for attunement.

Yet the LLM is also free of judgement. We might be less scared of saying things
into the machine then to each other. This leads to an interesting conclusion:
rather than doing more, faster, a human--LLM gestalt might do the same work more
securely and with more confidence as it is applied in low-stakes affective work.
(Of course I struggle to see the realization of behemoth valuations if that's
our best outcome.)

The LLM is not "infinitely malleable."

It is difficult to identify what is uncanny in the output of the machine, and
even more so to correct it. So we often don't.

## Desaturation

"The fading of color in work." As a consequence of discretization, cluttering
and decluttering strategies, and attunement, the "texture of labor […] loses
differentiation and alters the distribution of agency." We "manage outputs" more
than "craft" them. We "do[] more of what is easiest to automate and less of what
is most engaging." By containing all the boring stuff, the LLM made the sucky
parts of work more visible. Even "ok" work became "bland."

Doesn't that contraindicate the largest marketing machine we've ever seen?

The tedium becoming easier meant workers did more of it, not less. It reminds of
Amdahl's law in a perverse way. We do more of what's fast, not less.

Participants lived a kind of contradiction: they simultaneously knew the machine
didn't live up to expectations of time or tedium saved, and yet they relied on
the machine, they would "feel its absence."

## Conclusion

(Much of this comes from the paper's section on desaturation, but it makes a
better conclusion for this post.)

Driven by discretization, cluttering, and attunement into desaturation,
participants came to feel like a conduit for work rather than a source of work,.
Achieving results feels good, but the processing of producing them became
joyless.

The fruits of our participants labor had no "self" in it, from which it is easy
to feel estrangement, alienation, isolation.

The work was rarely transformative of subject and object, which describes "true
work." The work shifted from productive to logistical (and in our
hyper-financialized world, we already lack enough production to match capital!).

As the authors write:

> automation had led to automatism, a practice without attention and intention.
