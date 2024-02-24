---
title: 'Performance of Racket Pict Comparison'
tags: [racket, performance]
category: [ Blog ]
---

I get a brief glimpse of the performance characteristics of two methods for
comparing `pict`s for equality.

## Motivation

For recent work in the [Frosthaven
Manager](https://benknoble.github.io/frosthaven-manager), I want to quickly and
accurately compare two generated pictures (called
[`pict`](https://docs.racket-lang.org/pict/index.html)s in Racket parlance) for
equality. This must be accurate and fast to solve a user-experience problem:
interacting with onscreen elements of the Frosthaven Manager causes unrelated
items to flicker. I initially solved this in commit [8e6da62 (rich-text-view:
skip updates when content hasn't changed,
2024-02-04)](https://github.com/benknoble/frosthaven-manager/commit/8e6da623b613d286a8d24765c37307ccadba4981)
by comparing new content with old content to avoid re-rendering the same stuff.
But since pixel-for-pixel equivalent `pict`s may differ according to `equal?`, I
need a transformation `f` such that `(equal? (f p) (f q))` is true for
equivalent `pict`s `p` and `q`.

I believe such `pict`s are currently compared for pointer equality only (that
is, using `eq?` semantics) because a `pict` is a non-transparent structure. In
addition it is documented to contain something that is roughly like a procedure.
Procedures are compared for pointer equality, too; `(equal? (λ (x) x) (λ (x)
x))` does not hold.

A brief documentation search produced two promising candidates:
1. The procedure
   [`pict->argb-pixels`](https://docs.racket-lang.org/pict/Rendering.html#%28def._%28%28lib._pict%2Fmain..rkt%29._pict-~3eargb-pixels%29%29)
   returns the byte-vector corresponding to a bitmap of the picture.
   Byte-vectors can be compared for equality. While I expect that bitmaps lose
   fidelity compared to the internal representation, for the images used by the
   Frosthaven Manager the fidelity of the bitmap is sufficient. Below, I refer
   to this as the "bytes" method of comparison and the "bytes" transformer.
2. The class [`record-dc%`](https://docs.racket-lang.org/draw/record-dc_.html)
   behaves like a normal drawing context except that it records drawing actions.
   These recorded actions can be replayed to another context or extracted into a
   serializable format. This format is, coincidentally, suitable for comparison
   by `equal?` directly. Unlike `pict->argb-pixels`, using a `record-dc%`
   requires a little extra code:
   ```racket
   (define (pict->recorded-datum p)
     (let ([dc (new record-dc%)])
       (draw-pict p dc 0 0)
       (send dc get-recorded-datum)))
   ```
   I refer to this as the "record-dc" method of comparison and the "record-dc"
   transformer.

## Hypotheses

Recall that I have 2 requirements for the equality comparison: it must be
_accurate_ (I don't want to skip a needed redraw or perform an unnecessary one)
and _fast_ (it can't delay the rest of the application noticeably). As I thought
about the methods I was considering, I added an extra desideratum: because these
transformations will generate values that will be garbage post-comparison, the
results should not be wasteful with memory and therefore trigger more frequent
garbage collection that could result in an unresponsive application.
Fortunately, the application mostly operates at human timescales and has "idle"
time. Unfortunately, I cannot control the collector (or the duration of the
"idle" time) to guarantee that GC pauses only occur when they would go
completely unnoticed.

With these factors in mind, I formed the following hypotheses:
1. The bytes method and the record-dc method perform at roughly equal speeds.
2. The record-dc method uses more memory.

Hypotheses (1) is supported. In a shocking twist, it appears that the bytes
method uses marginally more memory (but this is "eyeball" statistics: I have not
performed a statistical test; I do not have a p-value; this does not generalize
beyond my dataset).

I arrived at these hypotheses by noting that both methods perform a similar
transformation: draw the picture and extract some comparable information. I
expected the bytes method to perform slightly faster on the assumption that
byte-vector comparison is fast and that the comparable values from the record-dc
transformer would be large enough in memory to slow down comparison. This latter
expectation is not supported by my data; indeed, the inverse (that the record-dc
method is faster) is.

## Experimental Method

I constructed a benchmarking program that could be run in a matrix of modes. A
parameter $$N$$ controls the number of iterations of each mode; what follows
describes a single iteration for each mode. The four modes are:
1. A time benchmark using the bytes method.
1. A time benchmark using the memory method.
1. A memory benchmark using the bytes method.
1. A memory benchmark using the memory method.

Since each iteration executes independent of the method, I will describe each
benchmark mode in terms of a general method $$M$$.

Each benchmark used a table of `pict` comparisons with 582 entries. This
resulted in 1164 applications of transformers per run. Each benchmark was run a
minimum of 10 times by `hyperfine`.

### Time Benchmarks

The time benchmark iterates the table of `pict` comparisons $$N$$ times; for
each, it compares two `pict`s (outputting timing information of the entire
comparison, which includes the use of the transformers, using the `time` form)
and checks that the result of the comparison is as expected.

Since `hyperfine` ran the time benchmarks 10 times with $$N=1$$, this results in
5820 data-points for each method for each of real, cpu, and gc time, for a grand
total of 11640 points.

### Memory Benchmarks

The memory benchmark iterates the table of `pict` comparisons $$N$$ times. For
each iteration of the table, we perform the ritualistic GC dance (call
`collect-garbage` 3 times) and measure current memory use. Then we construct the
objects that would be compared using the transformer under benchmark. Finally,
we print the difference of current memory use (after constructing the objects)
and original memory use (after garbage collection).

I cannot guarantee that GC does not occur during the iteration of the table,
which would skew results. An earlier version of the memory benchmark only
collected garbage before iterating the entire table and likely had to GC midway.
The current version may still GC midway, but it is far less likely now.

Since `hyperfine` ran the time benchmarks 10 times with $$N=1$$, this results in
5820 data-points for each method for a grand total of 11640 points.

## Results

Pretty pictures first. These are box and whisker plots that show mean, IQR, and
outliers.

![Time spent comparing picts][time-graph]

The time chart is segmented by where the time was spent. In real and cpu time,
the record-dc averages 2ms faster. Most gc times are 0.

![Memory use by pict transformers for comparison][memory-graph]

The memory chart shows that the record-dc averages less than 250KiB less memory
use, which is easier to see on a chart with no outliers.

![Memory use by pict transformers for comparison without outliers][memory-graph2]

Here are the `hyperfine` outputs at various commits.

```
commit 00366fdb3712bf4359c5a7dc551de2a0fc33e716
hyperfine 'racket bench.rkt --time --bytes -n 1 >> time-bytes' 'racket bench.rkt --time --record-dc -n 1 >> time-record-dc'
Benchmark 1: racket bench.rkt --time --bytes -n 1 >> time-bytes
  Time (mean ± σ):     10.036 s ±  0.044 s    [User: 9.491 s, System: 0.285 s]
  Range (min … max):    9.962 s … 10.086 s    10 runs

Benchmark 2: racket bench.rkt --time --record-dc -n 1 >> time-record-dc
  Time (mean ± σ):      8.798 s ±  0.049 s    [User: 8.283 s, System: 0.267 s]
  Range (min … max):    8.717 s …  8.851 s    10 runs

Summary
  racket bench.rkt --time --record-dc -n 1 >> time-record-dc ran
    1.14 ± 0.01 times faster than racket bench.rkt --time --bytes -n 1 >> time-bytes
```

This demonstrates that the record-dc method is slightly faster than the bytes
method.

```
commit a327c06ceb84b69daa6732ba698ffe6acc22e512
hyperfine 'racket bench.rkt --memory --bytes -n 1 >> memory-bytes' 'racket bench.rkt --memory --record-dc -n 1 >> memory-record-dc'
Benchmark 1: racket bench.rkt --memory --bytes -n 1 >> memory-bytes
  Time (mean ± σ):     10.493 s ±  0.064 s    [User: 9.948 s, System: 0.286 s]
  Range (min … max):   10.383 s … 10.586 s    10 runs

Benchmark 2: racket bench.rkt --memory --record-dc -n 1 >> memory-record-dc
  Time (mean ± σ):      9.213 s ±  0.053 s    [User: 8.700 s, System: 0.265 s]
  Range (min … max):    9.130 s …  9.303 s    10 runs

Summary
  racket bench.rkt --memory --record-dc -n 1 >> memory-record-dc ran
    1.14 ± 0.01 times faster than racket bench.rkt --memory --bytes -n 1 >> memory-bytes

commit 2fb05847453641fcfa400dfa34d2fa67beb7096b
hyperfine 'racket bench.rkt --memory --bytes -n 10 >> memory-bytes' 'racket bench.rkt --memory --record-dc -n 10 >> memory-record-dc'
Benchmark 1: racket bench.rkt --memory --bytes -n 10 >> memory-bytes
  Time (mean ± σ):     39.261 s ±  0.418 s    [User: 38.181 s, System: 0.544 s]
  Range (min … max):   38.926 s … 40.364 s    10 runs

Benchmark 2: racket bench.rkt --memory --record-dc -n 10 >> memory-record-dc
  Time (mean ± σ):     26.965 s ±  0.514 s    [User: 26.161 s, System: 0.378 s]
  Range (min … max):   26.271 s … 28.015 s    10 runs

Summary
  racket bench.rkt --memory --record-dc -n 10 >> memory-record-dc ran
    1.46 ± 0.03 times faster than racket bench.rkt --memory --bytes -n 10 >> memory-bytes

commit 4767dced4be0a77f4aab62f69f114d713fb19d7f
hyperfine 'racket bench.rkt --memory --bytes -n 1 >> memory-bytes' 'racket bench.rkt --memory --record-dc -n 1 >> memory-record-dc'
Benchmark 1: racket bench.rkt --memory --bytes -n 1 >> memory-bytes
  Time (mean ± σ):     267.591 s ±  5.458 s    [User: 266.095 s, System: 0.851 s]
  Range (min … max):   258.180 s … 274.836 s    10 runs

Benchmark 2: racket bench.rkt --memory --record-dc -n 1 >> memory-record-dc
  Time (mean ± σ):     269.610 s ±  2.811 s    [User: 267.713 s, System: 1.014 s]
  Range (min … max):   265.525 s … 274.013 s    10 runs

Summary
  racket bench.rkt --memory --bytes -n 1 >> memory-bytes ran
    1.01 ± 0.02 times faster than racket bench.rkt --memory --record-dc -n 1 >> memory-record-dc
```

These only demonstrate the speed (or lack thereof) of various versions of the
memory benchmarks. The last run produced the data-points described in
[Experimental Method](#experimental-method).

## Analysis

I find it hard to believe that constructing the comparison objects for 2 `pict`s
used 500–750KiB of memory regardless of method; that seems like too much. On the
other hand, I don't know Racket's memory model well.

It is clear that, for this sample, the record-dc method is more performant on
all axes I considered.

## Conclusion

I'll be adding record-dc method code to Frosthaven Manager soon.

### Appendix: Machine Information

- OS: macOS 12.7.2 21G1974 x86_64
- Kernel: 21.6.0
- CPU: Intel i7-4870HQ (8) @ 2.50GHz
- GPU: Intel Iris Pro, AMD Radeon R9 M370X
- Memory: 16384MiB

Benchmarks were run while the machine was under low load.

### Appendix: Full Benchmark Program

[The code is available on GitHub.](https://github.com/benknoble/pict-equal-bench)

```racket
#lang racket/base

(require pict
         racket/draw
         racket/class
         racket/match
         rackunit
         frosthaven-manager/elements
         (rename-in frosthaven-manager/testfiles/aoes/ring1
                    [aoe test1])
         (rename-in frosthaven-manager/testfiles/aoes/drag-down
                    [aoe test2])
         (rename-in frosthaven-manager/testfiles/aoes/speartip
                    [aoe test3])
         (rename-in frosthaven-manager/testfiles/aoes/unbreakable-wall
                    [aoe test4]))

(define (pequal-bytes? p q)
  (equal? (pict->argb-pixels p)
          (pict->argb-pixels q)))

(define (pict->recorded-datum p)
  (let ([dc (new record-dc%)])
    (draw-pict p dc 0 0)
    (send dc get-recorded-datum)))

(define (pequal-dc? p q)
  (equal? (pict->recorded-datum p)
          (pict->recorded-datum q)))

(define checks
  (append
   (list
    (list (test1) (test1) #t)
    (list (test2) (test2) #t)
    (list (test3) (test3) #t)
    (list (test4) (test4) #t)
    (list (test1) (test4) #f)
    (list (test2) (test3) #f))
   (for*/list ([element1 (list fire ice earth air light dark)]
               [element2 (list fire ice earth air light dark)]
               [procedure1 (list element-pics-infused
                                 element-pics-waning
                                 element-pics-unfused
                                 element-pics-consume)]
               [procedure2 (list element-pics-infused
                                 element-pics-waning
                                 element-pics-unfused
                                 element-pics-consume)])
     (list (procedure1 (element1))
           (procedure2 (element2))
           (and (equal? procedure1 procedure2)
                (equal? element1 element2))))))

(define (run-time-bench n pequal?)
  (for ([_i (in-range n)])
    (for ([check (in-list checks)])
      (match-define (list p q expected) check)
      (check-equal? (time (pequal? p q)) expected))))

(define (run-memory-bench n constructor)
  (for ([_i (in-range n)])
    (for ([check (in-list checks)])
      (collect-garbage)
      (collect-garbage)
      (collect-garbage)
      (collect-garbage)
      (define old (current-memory-use))
      (match-define (list p q _expected) check)
      (constructor p)
      (constructor q)
      (define new (current-memory-use))
      (println (- new old)))))

(module+ main
  (require racket/cmdline)
  (define constructor (make-parameter #f))
  (define comparator (make-parameter #f))
  (define bench (make-parameter #f))
  (define n (make-parameter 10))
  (define arg (make-parameter #f))
  (command-line
   #:once-any
   [("--bytes") "Benchmark using bytes"
                (constructor pict->argb-pixels)
                (comparator pequal-bytes?)]
   [("--record-dc") "Benchmark using record-dc%"
                (constructor pict->recorded-datum)
                (comparator pequal-dc?)]
   #:once-any
   [("--time") "Benchmark timing"
               (bench run-time-bench)
               (arg comparator)]
   [("--memory") "Benchmark memory"
                 (bench run-memory-bench)
                 (arg constructor)]
   #:once-each
   [("-n") N "Number of iterations [10]" (n (string->number N))]
   #:args ()
   (unless (and (bench) (n) (arg) ((arg)))
     (raise-user-error "Missing arguments"))
   ((bench) (n) ((arg)))))
```

[memory-graph]: {% link assets/img/pict-bench-memory.svg %}
[memory-graph2]: {% link assets/img/pict-bench-memory2.svg %}
[time-graph]: {% link assets/img/pict-bench-time.svg %}
