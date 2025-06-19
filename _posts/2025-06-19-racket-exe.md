---
title: A note about building executables with Racket
tags: [ racket ]
category: [ Blog ]
---

This information is collected from my and other Racketeers dive into the
documentation in one attempt to form a cohesive picture in response to the
question "How do I use custom icons with GUI executables?"

The extremely short version: changing the icon is something that happens at the
point where you build an executable, not when running inside `racket`, DrRacket,
etc. You control this by setting up your project as a package with an
`info.rkt`. See [Controlling `raco
setup`](https://docs.racket-lang.org/raco/setup-info.html).

Those docs will give you info for the `gracket-launcher-libraries` and
`gracket-launcher-names` directives, which in turn lead you to the
`racket-launcher-names` directive. That directive explains that it makes use of
`make-racket-launcher` under the hood, and you must infer that the `gracket-*`
directives must then use `make-gracket-launcher`.

The [docs for `make-gracket-launcher`][gracket-launcher] indicate that
`build-aux-from-file` is used to find auxiliary filenames for related assets,
and if you click through to the [docs for `build-aux-from-file`][aux] it
confirms that icons are included in those related assets. Ultimately what we
figured out was that `info.rkt` needs to include something like

```racket
(define gracket-launcher-names '("My App Name.app"))
(define gracket-launcher-libraries '("app.rkt"))
```

…where `app.rkt` is the file with a `main` submodule that starts the app's GUI.
And an `app.icns` file in the same folder as `app.rkt` is used for the program's
icon (png for linux).

When you do `raco setup mypackagename` it creates the executable with that icon.

Some of this is independently covered by [docs for `raco exe`][raco-exe], which
supports `--ico` (Windows), `--icns` (macOS), and `++aux` for general icons and
auxiliary files (which point you toward yet more docs about what you can give to
`++aux`).

[gracket-launcher]: https://docs.racket-lang.org/raco/exe.html#(def._((lib._launcher%2Flauncher..rkt)._make-gracket-launcher))
[aux]: https://docs.racket-lang.org/raco/exe.html#(def._((lib._launcher%2Flauncher..rkt)._build-aux-from-path))
[raco-exe]: https://docs.racket-lang.org/raco/exe.html
