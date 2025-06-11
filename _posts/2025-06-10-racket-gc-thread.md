---
title: A note about Racket's GC for threads
tags: [ racket, concurrency ]
category: [ Blog ]
---

Yes, Racket will collect as garbage a thread that is blocked on a channel that
can have no writers (according to Matthew Flatt).

Matthew also suggested a nice refinement of my program below that demonstrates
the effect. I'll show his first:

```racket
#lang racket

;; store a weak reference to the thread, but make sure the channel has no
;; writers
(define t
  (make-weak-box
   (let ()
     (define c (make-channel))
     (thread (thunk (sync c))))))

;; The (sync (system-idle-evt)) will not return until the thread has run as far
;; as it can, at which point it's GC-able. (The system-idle-evt constructor
;; exists essentially only for this kind of test/example.)
(sync (system-idle-evt))
(collect-garbage)
(weak-box-value t) ;=> #f
```

My original version was:

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
