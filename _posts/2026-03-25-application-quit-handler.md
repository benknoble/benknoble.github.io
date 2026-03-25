---
title: Notes on Racket quit handlers
tags: [ racket ]
category: [ Blog ]
---

Notes from Discord.

I recently found that, at least on Linux, the quit handler
`application-quit-handler` only closes the most recent window :/ not quite what
I was expecting.

But apparently I'm holding it wrong:

> [we're not] intended to call the `application-quit-handler` from code.
> Instead, I think it is a hook for reacting to requests from the desktop
> environment that the application please quit, just as the other handlers
> documented in that section respond to other events from the environment. In
> particular:
>
> > The default handler queues a call to the `can-exit?` method of the most
> > recently active frame in the initial eventspace (and then calls the frame’s
> > `on-exit` method if the result is true). The result is `#t` if the
> > eventspace is left with no open frames after `on-exit` returns, `#f`
> > otherwise.

([Documentation on Windowing Functions][docs])

[docs]: https://docs.racket-lang.org/gui/Windowing_Functions.html#(def._((lib._mred%2Fmain..rkt)._application-quit-handler))

Which of course makes quite a bit more sense, and should probably be stated in
documentation.

I had wanted to use it as the action for my “File > Quit” menu, which now just
uses `exit` (I have no special cleanup to do for the moment).

I know macOS automatically provides a Quit option on .apps, which I suppose is
an example of a “request[] from the desktop environment.” Do other DEs do
something similar? My Gentoo box is currently running i3 without a DE, so I
don’t know what typical Linux/Gtk behavior is, for example. Although a good many
programs don’t have a close/quit button, which seems to imply they assume the DE
will provide one. (I have keys in i3 to close them in that case.)

The `framework` module uses
[`file-menu:quit-callback`](https://docs.racket-lang.org/framework/Frame.html#%28meth._%28%28%28lib._framework%2Fmain..rkt%29._frame~3astandard-menus~3c~25~3e%29._file-menu~3aquit-callback%29%29)
which "by default goes through the exit-related hooks in the framework."

> On non-Mac platforms, applications are supposed to add a “File > Quit” item
> themselves: see `file-menu:create-quit?` from framework. But DEs do have other
> ways to ask an application to quit. The `application-quit-handler` docs don't
> mention other Unix, but, on KDE, right-clicking on DrRacket’s icon in my task
> bar and choosing Quit definitely goes through some graceful mechanism
> prompting me to save or cancel. Likewise if I'm logging out or rebooting. IIRC
> there's an XDG spec for how to ask an application to quit.

And others say

> For the File > Exit menu option in Molasses (which should probably be File >
> Quit), I do `(send frame on-exit)`. The default `on-exit` handler will in turn
> call `on-close`, which I overrode and put my custom Exit/Quit code.

This seems quite sensible also.
