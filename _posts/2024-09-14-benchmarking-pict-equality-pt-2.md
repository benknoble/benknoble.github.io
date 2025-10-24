---
title: 'Performance of Racket Pict Comparison, Part 2'
tags: [racket, frosthaven-manager, performance, statistics]
category: [ Blog ]
---

I eliminate "eyeball statistics" from [part 1][part_1]. This post is based on
[Chelsea Troy's "Data Safety"
series](https://chelseatroy.com/2021/02/26/data-safety-for-programmers/),
especially [Quantitative Programming Knife Skills, Part
2](https://chelseatroy.com/2021/03/12/quantitative-programming-knife-skills-part-2/).

As usual, all code is [available on GitHub](https://github.com/benknoble/pict-equal-bench).

## Problems

In the previous post, I eyeballed distributions from box-and-whisker plots (in
addition to relying on reported timings from hyperfine) to determine which
method of comparing `pict`s is faster. Today, we'll look at addressing two
limitations of that approach:

1. How confident are we that the true mean of relevant measurements is captured
   by the mean of our sample distribution? We'll compute confidence intervals
   for an appropriate distribution.
1. How likely is it that the distributions actually differ for a reason other
   than random chance? We'll use statistical tests to measure the probability of
   difference being attributable to random chance (the "null hypothesis").

First, though, we've got to talk about distributions.

## Distributions

We have (by computation) a mean and standard deviation for various facets of our
[data][data]. We have enough data that assuming a normal distribution is not
unreasonable; let's take a look. For the time benchmark data, the following code

```racket
(require sawzall
         data-frame
         threading
         math/statistics)

(define (v-μ xs)
  (exact->inexact (mean (vector->list xs))))

(define (v-σ xs)
  (stddev (vector->list xs)))

(define t-short (df-read/csv "time.csv"))

(~> t-short
    (group-with "bench")
    (aggregate [cpu-μ (cpu) (v-μ cpu)]
               [cpu-σ (cpu) (v-σ cpu)]
               [real-μ (real) (v-μ real)]
               [real-σ (real) (v-σ real)]
               [gc-μ (gc) (v-μ gc)]
               [gc-σ (gc) (v-σ gc)])
    (show everything))
```

produces

```
data-frame: 2 rows x 7 columns
┌──────────────────┬─────────┬──────────────────┬──────────────────┬─────────────────┬───────────────────┬────────────────────┐
│cpu-σ             │bench    │real-μ            │real-σ            │cpu-μ            │gc-σ               │gc-μ                │
├──────────────────┼─────────┼──────────────────┼──────────────────┼─────────────────┼───────────────────┼────────────────────┤
│1.477002129744432 │bytes    │4.225773195876289 │1.4978411739022484│4.175601374570447│0.15933274204104092│0.006529209621993127│
├──────────────────┼─────────┼──────────────────┼──────────────────┼─────────────────┼───────────────────┼────────────────────┤
│1.1370657205199777│record-dc│2.0853951890034366│1.148475651239016 │2.05893470790378 │0.16564821501258256│0.007216494845360825│
└──────────────────┴─────────┴──────────────────┴──────────────────┴─────────────────┴───────────────────┴────────────────────┘
```

Let's plot these ([code][code]):

![CPU time normal distributions][cpu-normal]
![Real time normal distributions][real-normal]
![GC time normal distributions][gc-normal]

By now you might have realized that negative times don't make sense… this
suggests the normal distribution is not an appropriate distribution for
comparison. [It appears that the exponential or Weibull distributions might
model this process better](https://stats.stackexchange.com/a/203958), but for
now we'll continue taking timings and memory usage to be normally distributed
for simplification.

Here are the equivalent values and plots for memory (all in MiB):

```
data-frame: 2 rows x 3 columns
┌───────────────────┬──────────────────┬─────────┐
│memory-σ           │memory-μ          │bench    │
├───────────────────┼──────────────────┼─────────┤
│0.22898033579570978│0.6772037663410619│bytes    │
├───────────────────┼──────────────────┼─────────┤
│0.23704268897914643│0.5486571085821722│record-dc│
└───────────────────┴──────────────────┴─────────┘
```

![Memory normal distributions in MiB][memory-normal]

## Confidence Intervals

To compute a confidence interval, we'll take the distributions to be
t-distributed and compute properties of the t-statistic (for $$\alpha = 0.05$$,
a 95% confidence interval). This interval tells us where the true mean falls
with 95% probability.

Let's use a critical value of 1.96, which corresponds to an assumption that the
distributions are normal (given our large sample size, the t-distribution is
close to normal) and a 95% confidence interval. The formula (letting $$s$$ be
the sample standard deviation, $$\bar{x}$$ the sample mean, and $$N$$ the number
of samples) is

$$ \bar{x} \pm 1.96 \frac{s}{N} $$

Here are the low and high offsets of the intervals for memory and time:

- memory
    - bytes: [0.6771 MiB, 0.6773 MiB]
    - record-dc: [0.5486 MiB, 0.5487 MiB]

    ![Memory confidence intervals in MiB][memory-confidence]

- cpu
    - bytes: [4.175, 4.176]
    - record-dc: [2.0586, 2.0593]

    ![CPU time confidence intervals][cpu-confidence]

- real
    - bytes: [4.225, 4.226]
    - record-dc: [2.085, 2.086]

    ![Real time confidence intervals][real-confidence]

- gc
    - bytes: [0.00648, 0.00658]
    - record-dc: [0.00716, 0.00727]

    ![GC time confidence intervals][gc-confidence]

The plots are zoomed in because the intervals are so narrow thanks to our high
number of samples. We can be very confident that our sample means are close to
the true mean.

## Statistical tests

We want to compare the memory distributions across both benchmarks, and each of
the real, cpu, and gc times across both benchmarks. We'll use the
[`welch-t-test` function from the `t-test`
library](https://docs.racket-lang.org/t-test/index.html)[^1], since we can't assume
the variances are equal (though eyeball statistics suggests that gc variance is,
which is sensible since most gc times are 0).

The code to compute a t-test for memory distributions is short:
```racket
(require threading
         data-frame
         sawzall
         t-test)

(define m
  (~> "memory.csv" df-read/csv
      (create [memory (memory) (/ memory (expt 2 20))])))

(apply
 welch-t-test
 (~> m
     (split-with "bench")
     (map (λ (df)
            (~> df
                (slice ["memory"])
                (df-select "memory")))
          _)))
```

The result for a p-value of $$0.01$$ is $$1.53 \times 10^{-187}$$. That is, we
can be extremely confident that the distributions have different means: we
reject the null hypothesis that the distributions have the same mean as the
likelihood of this sample occurring given said hypothesis is nearly 0.

Of note, this test suggests the distributions are different _despite
having close means_: the difference between the means (0.12854665775888974) is
23.42% of the smaller of the two means and 18.98% of the larger.

The code for time distributions is parameterized on the column:

```racket
(require threading
         data-frame
         sawzall
         t-test)

(define t (df-read/csv "time.csv"))

(for/list ([column '("cpu" "real" "gc")])
  (list column
        (apply
         welch-t-test
         (~> t
             (slice (all-in (list "bench" column)))
             (split-with "bench")
             (map (λ (df)
                    (~> df
                        (slice column)
                        (df-select column)))
                  _)))))
```

The results (again with p-value $$0.01$$):
- cpu: $$0.0$$
- real: $$0.0$$
- gc: $$0.8196$$

I'm actually shocked that the procedure produced an (inexact) 0, and I checked
the data being fed in. I can't explain the result beyond gesturing at floating
point math; there's no statistical realm where we accept that this occurrence is
impossible. For now, I'll content myself with supposing that the calculation
produces such a small number that even Racket can't keep up, and reject the null
hypothesis for CPU and real times (there is a statistically meaningful
difference in the time the two procedures take).

For GC times, of course, there is insufficient evidence to reject the null
hypothesis _as expected_. Most GC times are 0! It's reasonably more likely that
the underlying distributions are actually the same one.

## Conclusion

I feel justified in my choice of method based on the data from last time and
satisfied that I'm not relying entirely on eyeball statistics. The lack of
explanation for $$0.0$$ is dissatisfying…

[^1]: There have been [several interesting conversations about performing
    t-tests within Racket
    lately](https://racket.discourse.group/t/could-the-t-student-distribution-be-included-in-the-math-module/2999),
    which lead to me include these additional links: [pasted
    code](https://onecompiler.com/racket/42j3n4wdn), [@soegaard's
    fork](https://github.com/soegaard/math/blob/student-t/math-lib/math/private/distributions/impl/student-t.rkt)
    [how to build the distribution from its
    parts](https://math.stackexchange.com/questions/4367570/transform-students-t-distribution-to-beta-distribution).

[part_1]: {% link _posts/2024-02-15-benchmarking-pict-equality.md %}
[data]: https://github.com/benknoble/pict-equal-bench
[code]: https://github.com/benknoble/pict-equal-bench
[cpu-normal]: {% link assets/img/pict-time-bench-cpu-normal.svg %}
[real-normal]: {% link assets/img/pict-time-bench-real-normal.svg %}
[gc-normal]: {% link assets/img/pict-time-bench-gc-normal.svg %}
[memory-normal]: {% link assets/img/pict-time-bench-memory-normal.svg %}
[memory-confidence]: {% link assets/img/pict-time-bench-memory-confidence.svg %}
[cpu-confidence]: {% link assets/img/pict-time-bench-cpu-confidence.svg %}
[real-confidence]: {% link assets/img/pict-time-bench-real-confidence.svg %}
[gc-confidence]: {% link assets/img/pict-time-bench-gc-confidence.svg %}
