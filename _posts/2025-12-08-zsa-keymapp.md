---
title: Packaged ZSA Keymapp for Gentoo
tags: [gentoo]
category: Blog
---

My [Gentoo overlay](https://github.com/benknoble/benknoble-gentoo-overlay) now
contains an ebuild for ZSA's Keymapp application.

The licensing situation is unclear, so I've marked it "unknown" for now. In
addition, the ebuild is "live" (so only rebuilds with `emerge @live-rebuild`);
ZSA doesn't publish versioned archives, as far as I can tell, so we can only
grab the latest. In spite of being version 9999, the ebuild is not actually live
in the sense of `@live-rebuild`. Strange.

When the archive has actually been updated, I'll have to use `ebuild $(equery w
zsa-keymapp) manifest` or similar to update the Manifest. (For some reason,
`pkgdev` didn't work on this one? And a couple of live ebuilds I checked don't
have manifest information, but they also use the Git eclass for fetching.)
