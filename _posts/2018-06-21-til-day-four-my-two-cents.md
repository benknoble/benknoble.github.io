---
title: Day Four, My Two Cents
tags: [ til, infra, intern ]
category: Work
---

Penny for your thoughts?

## Today I Learned

2. How to use Cent OS
1. How to configure a proxy
3. Who my boss-boss is, and how I fit into Nuage Networks

So I got a temporary laptop while my work one is getting re-imaged (update: this
failed, so tomorrow I get to troubleshoot a boot failure with IT. Yay.). The
loaner is running Cent OS 7, and I have a love-hate relationship so far. I love
linux, but the keyboard is getting in my way. None of my shortcuts work, and I
keep hitting `<CapsLock>` instead of `<Control>` because I haven't figured out
how to do that remapping yet. Plus, there's the proxy (read on). Overall, a
positive experience though, because it meant I finally have all my accounts
(except possibly an `ssh` account on the internal servers for doing that
work...).

Also, the trackpad scroll sucks.

Apparently, `/etc/environment` needs to know about the work proxy through
`http_proxy` and the `https` and uppercase variants, as well as `no_proxy`.
Then, it probably should go in `/etc/bashrc` or another file that is sourced by
every shell to be exported. Finally, I still had to configure Firefox and the
network individually (and Slack *still* wouldn't get through it!).

We had a big luncheon with the boss-boss today (free food!). He gave everybody a
big spiel about how we need to step up, about running tests and not shipping
broken or poor-quality products. I sensed there was some history there. But he
also said we have some good problems (too much business), and the problems are
all fixable. In other words, we all need to do better of speaking up and
stepping up to work on things outside of our own areas.

I learned from this that my role in Infra is to make sure everybody else can do
their jobs effectively--they have better things to do than to wait on builds to
finish.

If you haven't figured out the title yet, the first Cent is the OS, and the
second is me stepping up and speaking up about things at the office.
