---
title: 'Developer Experience, Redux'
tags: [ developer experience ]
category: [ Blog ]
---

Another redux of some DevEx-relevant articles.

## [Normalization of Deviance](http://danluu.com/wat/)

Many parts of this post are focused on unregulated environments (so not my
workplace, which is tied to banking and credit cards). Still, some things
resonate:

> Often, they try to fix things, and then leave when they can't make a dent.

> The data are clear that humans are really bad at taking the time to do things
> that are well understood to incontrovertibly reduce the risk of rare but
> catastrophic events. We will rationalize that taking shortcuts is the right,
> reasonable thing to do. There's a term for this: the normalization of
> deviance. It's well studied in a number of other contexts including
> healthcare, aviation, mechanical engineering, aerospace engineering, and civil
> engineering, but we don't see it discussed in the context of software. In
> fact, I've never seen the term used in the context of software.

> Turning off or ignoring notifications because there are too many of them and
> they're too annoying? An erroneous manual operation?

> How many technical postmortems start off with “someone skipped some steps
> because they're inefficient”, e.g., “the programmer force pushed a bad config
> or bad code because they were sure nothing could go wrong and skipped
> staging/testing”?

> People don't automatically know what should be normal, and when new people are
> onboarded, they can just as easily learn deviant processes that have become
> normalized as reasonable processes.

And the list of examples goes on! One conclusion seems clear: building reliable
software demands rooting these out mercilessly. That means efficiency (hello,
developer experience!) and guardrails around manual operations that demand
sanity-checks.

Finally, do this:

> - Pay attention to weak signals
> - Resist the urge to be unreasonably optimistic
> - Teach employees how to conduct emotionally uncomfortable conversations
> - System operators need to feel safe in speaking up
> - Realize that oversight and monitoring are never-ending

If I don't have much to add, it's because there isn't, frankly, much else to
say. Go read the original.

## [The chilling effect versus attempts to fix things](https://rachelbythebay.com/w/2021/04/30/speech/)

Building on the previous article: we've got to talk about things and then fix
them. When you have "WTF" moments---see above---say something. _Create a weak
signal._ (And then pay attention to and amplify others.)

## [The Honest Troubleshooting Code of Conduct](https://rachelbythebay.com/w/2021/05/01/code/)

I think Bryan Cantrill would agree with this sentiment: the resounding theme of
the CoC above is "We are here to make things better." We are here to improve the
customers lives. That comes above all, and treating that as shared vision will
get us much further than bickering about blame or passing off issues on other
folks.

## [Baking those potatoes with microservices and vendors](https://rachelbythebay.com/w/2020/08/17/potato/)

Accountability! Rawr!

This is more of the same, actually: own the problem and fix it, even if you
think it comes from another place. Don't toss the hot potato to the next person.

Don't create gaps in responsibility. Fill them.

## [Infra teams: good, bad, or none at all](https://rachelbythebay.com/w/2020/05/19/abc/)

Strong language makes a point, even if I don't appreciate the ad hominem
("pathetic mass of losers"). My workplace feels like it went from C to something
that resembles this part of B:

> Random product people now have to know about arbitrary crap enforced by
> someone else like "kubelets" and "Jenkins". They burn their cycles and sanity
> on terrible systems instead of improving the experience for the company's end
> user.

We keep making improvements, but getting to A requires more than a series of
band-aids: it requires deep investment that we just aren't seeing be made.
