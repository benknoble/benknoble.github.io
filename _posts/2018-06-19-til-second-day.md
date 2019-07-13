---
title: Second Day
tags: [ til, infra, intern, ixia, shell ]
category: Blog
---

My second day at work--progress was made.

## Today I Learned

1. "Agile" is a set of principles and values, not methodologies
2. DHCP configuration can specify IP addresses and MAC addresses
3. Communication is essential
4. I can still write shell scripts

Nuage's infra team uses the [Agile][] methodology as a guiding practice for
making decisions and developing software (read: meeting our clients' needs--this
often includes hardware builds). I did some further digging, thinking Agile was
things like project boards and standups. Turns out, it's a set of [principles
and values][prince] that should guide decisions towards certain goals. A little like
the [scout oath][] and law.

While configuring the IXIA again today, we had to get it up and running on the
network, which meant finding and assigning it a suitable IP as well as editing
the [DHCP][] configuration, which lives in a [git][] repo. We fork/clone/branch/PR for
the DHCP, and reboot the IXIA, and voilà ! (Actually, we had to do this twice.
The IXIA's MAC address changed on the second reboot.)

I'm unfortunately still waiting on some of the corporate login things, so I
can't access email or get infra LDAP credentials to use with [Slack][], [ssh][], or any
of our other tools/communication protocols. It's quickly becoming a problem.

I wrote a [script][] to make [til][]s easier!

[Agile]: https://linchpinseo.com/the-agile-method/
[prince]: https://www.youtube.com/watch?v=Z9QbYZh1YXY&index=41&t=0s&list=WL
[scout oath]: https://www.scouting.org/discover/faq/question10/
[DHCP]: https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol
[git]: http://gitimmersion.com
[Slack]: https://slack.com
[ssh]: https://en.wikipedia.org/wiki/Secure_Shell
[script]: {{ site.github.repository_url }}/blob/master/til/new
[til]: /tags#til
