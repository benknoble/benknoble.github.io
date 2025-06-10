---
title: A note about Racket's GC for threads
tags: [ racket, concurrency ]
category: [ Blog ]
---

Yes, Racket will collect as garbage a thread that is blocked on a channel that
can have no writers (according to Matthew Flatt).

This little program demonstrates the effect (I think):

```racket
#lang racket

;; store a weak reference to the thread, but make sure the channel has no
;; writers
(define t
  (make-weak-box
   (let ()
     (define c (make-channel))
     (thread (thunk (sync c))))))

;; wait for the GC to collect…
(let loop ()
  (match (weak-box-value t)
    [(? thread?)
     ;; …by forcing it (but not too aggressively)
     (collect-garbage)
     (loop)]
    [#f (displayln "thread was GC'd")]))
```

It reliably prints and exits within a second or 2 on my machine.
