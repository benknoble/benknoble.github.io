---
title: Breaking Changes in Dracula Pro for Vim
tags: [ dracula ]
category: [ Blog ]
---

PSA: If you use Dracula Pro, the filenames were changed recently.

There is an agglomerate Dracula Pro Git repository that contains sources for all
the Pro themes. There is also a seperate repo for each application.

While doing my usual maintenance to pull changes from the FOSS Dracula theme for
Vim, I noticed a commit in the agglomerate repo that changed all instances of
`dracula_pro` to `dracula-pro`, including other underscores. I have, despite my
misgivings, cherry-picked that change back into the Vim-only Pro repo.

So, if you pull from either the agglomerate repo after 14th August or the
Vim-only repo after today (22nd August), you'll need to adjust your invocations
of `:colorscheme` or your `ColorScheme` autocommands for Vim. Other applications
may be similarly affected.
