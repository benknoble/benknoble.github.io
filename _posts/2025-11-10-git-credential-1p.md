---
title: Packaging git-credential-1password
tags: [gentoo, git]
category: Blog
---

I'm proud to say that
[packaging](https://github.com/benknoble/benknoble-gentoo-overlay/commit/7f705e8db484dda377bfaa22d661ebf46b280ca8)
this [1password-based credential
helper](https://github.com/ethrgeist/git-credential-1password), at least for my
personal overlay, was fairly easy.

The gist was:

1. Create an overlay. I did `doas eselect repository create benknoble
   ~/code/benknoble-gentoo-overlay`, then `git init` inside that directory.
1. Write the ebuild.
1. Update the manifest: `pkgdev manifest -d tmp $eb && rm -r tmp`
1. Test it: `doas ebuild $eb clean install` and verify all looks good
1. Commit and publish

Note that the Portage repository is not sync'able directly this way; it's "live"
in the sense that updates are immediately reflected on the system. So I could
`doas emerge -av --autounmask git-credential-1password` even before the last
step. Meanwhile, _users_ who want the overlay but not to maintain it should use
a different command listed in the overlay's README to install the repo.
