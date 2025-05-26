---
title: 'Status Badges'
tags: [ 'project-management' ]
category: Blog
---

Today I made some status badges to represent the quality of the code I publish
on the internet. Here they are.

> Inspired heavily by [arp242](https://arp242.net/project-status-badges.html).
> See his post for more details on semantics.

Except for "archived," many of these badges also answer the question ["Is this
project still
maintained"](https://dammit.nl/link-is-this-project-still-maintained.html) in
the affirmative, but that may not mean what you think. See the linked article
for details.

- [![This project is considered experimental](https://img.shields.io/badge/status-experimental-critical.svg)](https://benknoble.github.io/status/experimental/)

  May work, or may sacrifice your first-born to Justin Bieber.

- [![This project is considered stable](https://img.shields.io/badge/status-stable-success.svg)](https://benknoble.github.io/status/stable/)

  Should work for most purposes; is reasonably bug-free and documented.

- [![This project is considered finished](https://img.shields.io/badge/status-finished-success.svg)](https://benknoble.github.io/status/finished/)

  Does what it needs to do and there are no known bugs; don’t expect any large
  changes or feature additions.

- [![This project is archived](https://img.shields.io/badge/status-archived-critical.svg)](https://benknoble.github.io/status/archived/)

  The author has stopped working on it, but should still work and may still be
  useful.

- [![This project is personal](https://img.shields.io/badge/status-personal-important.svg)](https://benknoble.github.io/status/personal/)

  Works, probably, for the author. Not intended to work for others, but still
  public.

And the markdown:

```
[![This project is considered experimental](https://img.shields.io/badge/status-experimental-critical.svg)](https://benknoble.github.io/status/experimental/)
[![This project is considered stable](https://img.shields.io/badge/status-stable-success.svg)](https://benknoble.github.io/status/stable/)
[![This project is considered finished](https://img.shields.io/badge/status-finished-success.svg)](https://benknoble.github.io/status/finished/)
[![This project is archived](https://img.shields.io/badge/status-archived-critical.svg)](https://benknoble.github.io/status/archived/)
[![This project is personal](https://img.shields.io/badge/status-personal-important.svg)](https://benknoble.github.io/status/personal/)
```

See [my Dotfiles]({{ site.data.people.benknoble.dotfiles }}) for a vim command I
use to insert the markdown.
