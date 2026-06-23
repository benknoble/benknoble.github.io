---
title: Improving Git Search Performance
tags: [ git ]
category: [ Blog ]
---

In reply to [Searching for and navigating Git commits](https://alexharri.com/blog/searching-and-navigating-git-commits).

The below advice on performance applies equally to `git log`'s other search
modes (`--grep`, `-G`) and to `git grep`, though I've never found `git grep` to
be slow.

Alex Harri wrote an excellent piece explaining how they often need more context
when examining a piece of code, and Git provides tools for recovering that
context.

Towards the end, they wrote:

> If your codebase is significantly larger, you may run into performance
> bottlenecks. If you do, I’d love to hear how you work around them!

This is my reply.

## Performance advice

My typical advice is to narrow the search scope:

- give some pathspecs to the log (`git log -S<text> -- path spec …`); use `git
  grep` or your knowledge of the architecture to suggest useful areas
- limit with date options (`--since`, `--until`)
- limit by author or committer
- limit by revision range (e.g., `vX..vX+1` if the feature was introduced in
  `vX+1`)
- turn off any external diffing or text conversions you might have configured
  (`--no-ext-diff`, `--no-textconv`)

Or, we can do the equivalent of `git log -S<text> --oneline | head -n1` and then
feed the preimage and pathspec of the "interesting bits" back into `-S`,
assuming the first hit is useful.

Of course all of these limit the search, so therefore risk missing things that
are interesting. But they are typically orders of magnitude faster, depending on
how much you cut away in scope.

## Example

A somewhat toy example I use at work to demonstrate the speedup is the Vim
source code; compare performance of

    git log -S term_list
    git log -S term_list v8.0.0000..v9.0.0000
    git log -S term_list -- src/{evalfunc,terminal}.c
    git log -S term_list v8.0.0000..v9.0.0000 -- src/{evalfunc,terminal}.c

I happened to be looking for the introduction of a feature (the `term_list()`
function); my first search above was too slow. I narrowed by knowing that it was
released sometime between Vim 8 (8.1 was the first release with `:terminal`) and
Vim 9, so I cast a somewhat wide net of revisions. In hindsight, limiting
between Vim 8 and Vim 8.1 would have been much faster. I also could see from
`git grep term_list` that the relevant definitions were limited to 2 source
files.

On my older machine, here's some information about my current checkout of Vim:

- Commit: d167c50de4 (patch 9.2.0707: completion: popup misplaced when text before it is concealed, 2026-06-22)
- I have Vim's history grafted on [as described in the vim-history repository](https://github.com/vim/vim-history#merge-the-whole-history)
- `git repo structure --format=table`

    ```
    | Repository structure | Value      |
    | -------------------- | ---------- |
    | * References         |            |
    |   * Count            |  22.04 k   |
    |     * Branches       |      2     |
    |     * Tags           |  21.50 k   |
    |     * Remotes        |    340     |
    |     * Others         |    199     |
    |                      |            |
    | * Reachable objects  |            |
    |   * Count            | 265.87 k   |
    |     * Commits        |  26.54 k   |
    |     * Trees          |  87.25 k   |
    |     * Blobs          | 148.92 k   |
    |     * Tags           |   3.17 k   |
    |   * Inflated size    |  11.33 GiB |
    |     * Commits        |  16.16 MiB |
    |     * Trees          | 567.11 MiB |
    |     * Blobs          |  10.76 GiB |
    |     * Tags           |   2.95 MiB |
    |   * Disk size        | 344.03 MiB |
    |     * Commits        |  10.97 MiB |
    |     * Trees          |  27.90 MiB |
    |     * Blobs          | 302.83 MiB |
    |     * Tags           |   2.32 MiB |
    ```
- `git repo info --all`

    ```
    layout.bare=false
    layout.shallow=false
    object.format=sha1
    references.format=files
    ```

(I haven't tried to see if converting to reftables are more performant for these
searches, but I somehow doubt it unless you're giving `--all` to `git log`,
which would broaden the scope, not limit it.)

I have Git's automatic maintenance enabled, so most objects are packed (346
loose objects; 139 info and pack files, including a multi-pack-index and commit
graph).

### Timing

    benchmarks=(
        # 'git log -S term_list'
        # too slow!
        'git log -S term_list v8.0.0000..v9.0.0000'
        'git log -S term_list -- src/{evalfunc,terminal}.c'
        'git log -S term_list v8.0.0000..v9.0.0000 -- src/{evalfunc,terminal}.c'
    )
    hyperfine "${benchmarks[@]}"

    Benchmark 1: git log -S term_list v8.0.0000..v9.0.0000
      Time (mean ± σ):     17.536 s ±  0.138 s    [User: 14.442 s, System: 3.065 s]
      Range (min … max):   17.435 s … 17.920 s    10 runs

    Benchmark 2: git log -S term_list -- src/{evalfunc,terminal}.c
      Time (mean ± σ):      1.872 s ±  0.002 s    [User: 1.758 s, System: 0.106 s]
      Range (min … max):    1.868 s …  1.875 s    10 runs

    Benchmark 3: git log -S term_list v8.0.0000..v9.0.0000 -- src/{evalfunc,terminal}.c
      Time (mean ± σ):      1.009 s ±  0.005 s    [User: 0.926 s, System: 0.077 s]
      Range (min … max):    1.002 s …  1.018 s    10 runs

    Summary
      git log -S term_list v8.0.0000..v9.0.0000 -- src/{evalfunc,terminal}.c ran
        1.86 ± 0.01 times faster than git log -S term_list -- src/{evalfunc,terminal}.c
       17.38 ± 0.16 times faster than git log -S term_list v8.0.0000..v9.0.0000

And using the hindsight to limit to Vim 8.1:

    Benchmark 1: git log -S term_list v8.0.0000..v8.1.0000
      Time (mean ± σ):      2.720 s ±  0.091 s    [User: 2.265 s, System: 0.437 s]
      Range (min … max):    2.650 s …  2.891 s    10 runs

    Benchmark 2: git log -S term_list -- src/{evalfunc,terminal}.c
      Time (mean ± σ):      1.923 s ±  0.039 s    [User: 1.802 s, System: 0.112 s]
      Range (min … max):    1.894 s …  2.008 s    10 runs

    Benchmark 3: git log -S term_list v8.0.0000..v8.1.0000 -- src/{evalfunc,terminal}.c
      Time (mean ± σ):     228.3 ms ±   2.8 ms    [User: 201.4 ms, System: 22.6 ms]
      Range (min … max):   224.8 ms … 232.1 ms    12 runs

    Summary
      git log -S term_list v8.0.0000..v8.1.0000 -- src/{evalfunc,terminal}.c ran
        8.42 ± 0.20 times faster than git log -S term_list -- src/{evalfunc,terminal}.c
       11.91 ± 0.42 times faster than git log -S term_list v8.0.0000..v8.1.0000

Sub-second results for the fully limited version!
