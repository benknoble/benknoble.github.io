---
title: A note about making Racket languages without installing them as a package
tags: [ racket ]
category: [ Blog ]
---

This trick comes from Matthew Flatt via the Racket Discord.

Usually, when creating a Racket `#lang` and customizing the reader, the reader
needs to produce a module form like

```racket
(module <name> <initial-import-module>
  body)
```

and the `<initial-import-module>` is best resolved as a reference to an
installed collection. That is, instead of `"mylang/expander.rkt"`, we should use
`mylang/expander`: the former is resolved relative to the PWD of the module
being expanded!

To make this work typically requires an installed package or linked files. This
is not a big hurdle for most Racket hackers, but might be confusing for
students.

When using `#lang s-exp`, of course, you can provide a relative path to an
expander module. This works if you don't need a custom reader. If you do, the
language syntax is restricted so that `#lang "mylang.rkt"` will never work.

We _can_ use a trick so that our reader can output a variant on the original
relative module path, though. That means our custom reader can yield an expander
module that isn't in an installed package, like the title suggests.

We need to create a module path that works regardless of location, but derive it
from the relative path. (You'll still need non-relative paths to make
documentation work everywhere, I think.)

Here's the code.

```racket
(module reader syntax/module-reader
  #:language (collapse-module-path-index
              (module-path-index-join "mylang/expander.rkt"
                                      (variable-reference->module-path-index
                                       (#%variable-reference))))
  (require syntax/modcollapse))
```

Matthew says:

> I'm not sure this solves any problem for you, but you can make a module path
> within `syntax/module-reader` relative by using `#:language`, which has an
> expression afterward instead of a literal. (It's something I've wanted often
> enough that `rhombus/reader` treats a relative path like this, instead of like
> `syntax/module-reader`).
