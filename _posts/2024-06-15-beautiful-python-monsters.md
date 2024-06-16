---
title: 'Re: Beautiful Python Monsters'
tags: [python, racket, fp]
category: [ Blog ]
---

Making flaky tests pass cries out for functional-programming idioms.

While reading [A beautiful Python
monstrosity](https://treyhunner.com/2024/06/a-beautiful-python-monstrosity/), I
was struck by several thoughts. Perhaps performance tests shouldn't be automated
with the same tools as unit tests? Is there a better way to write flaky tests?

## Automatic performance tests

A unit test doesn't seem to be the best way to describe a performance test. More
likely, we want to set up a benchmarking harness, run the programs, and measure
various performance indicators. [This can be done automatically in a build
pipeline](https://github.com/drym-org/qi/blob/070ffc5e0d2e3a581a1bc11acd391e980dbdd328/.github/workflows/benchmarks.yml),
for example.

If these measurements are collected on each run we can perform analyses. For
example:

- Graph each run (with suitable titles) or make a [trend
  analysis](https://drym-org.github.io/qi/benchmarks/).
- Perform [statistical
  tests](https://chelseatroy.com/2021/02/26/data-safety-for-programmers/)
  between runs to see if the change was meaningful.

All of this can also be automated. I wouldn't write any of it as a unit test,
however.

The examples in the original post also seem to concentrate on algorithmic (time)
complexity; this can be done with statistical tests, too, given a wealth of
data. It's not something I want to run as part of the (local) unit tests,
though. If it's important enough to block PRs, put it in the build pipeline (and
I should be capable of running it locally; it shouldn't be on by default,
though).

## Flaky tests

An orthogonal concept: How do we make flaky tests less flaky? We should engineer
the tests to be less reliant on flakiness, but automatically repeating the tests
is a reasonable hack in the meantime.

Here's my transcribed Racket `repeat-flaky` procedure, which doesn't require
decorators or other ideas:

```racket
(define (repeat-flaky test [n 10])
  (match n
    [0 (test)]
    [(? positive? m)
     (with-handlers ([exn:fail? (λ (_exn) (repeat-flaky test (sub1 n)))])
       (test))]))

;; Example:
(repeat-flaky (thunk (check-equal? (random 1 3) (random 1 3))))
```

The core idea is to pass functions around. Python makes this hard because its
`lambda` doesn't permit arbitrary functions; the decorator over an unnamed
function is essentially recreating higher-order functions receiving anonymous
functions. This is thus the essence of repeating fallible tests; a
generalization allows the `exn:fail?` test to be replaced by the client or for
subsequent invocations to know about the caught exception by having it passed as
an optional argument.

The `thunk` could be eliminated (from surface syntax) by a macro if desired.

This works without needing `nonlocal`, by the way, since the Racket equivalent
of Python's `a = 1` that automatically introduces `a` is `(let ([a 1]) …)` or
`(define a 1)`. This isn't mutation, it's binding. Further, if you want to refer
to `a` from a higher scope, you do so by writing `a` (as long it isn't
shadowed), even with `set!`. Lexical scoping rules give you predictable control
of which identifiers refer to which bindings in each part of the program text.

The ability to properly nest `repeat-flaky` makes a lot of the need for mutation
(and thus complicated scope references) go away, though:

```racket
(repeat-flaky
  (thunk
    (define micro-time …)
    (define tiny-time …)
    (check … micro-time tiny-time …)
    (repeat-flaky
      (thunk
        (define small-time …)
        ;; we have access to micro, tiny here
        (check … micro-time tiny-time small-time …)))))
```

Each nesting is repeated, however, so this singly-nested flaky test could run up
to 25 times (instead of the original's 5). This could be a feature, though, and
can be controlled with the optional repeat argument.

## Conclusions

1. Take a hard look at what your goals for performance tests are. The original
   post wanted them to predictably, consistently pass and fail like unit tests
   and run quickly. I'm not sure that's the best methodology for comparing
   performance or for testing algorithmic time complexity.
1. The essence of repeating fallible tests can be implemented by higher order
   functions. An abuse of Python's decorators allows Python to pass unnamed
   functions to higher-order functions, working around a language deficiency.
   Python's `lambda` is not.
