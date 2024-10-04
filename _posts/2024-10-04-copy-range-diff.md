---
title: 'Copying a git-range-diff to GitHub'
tags: [git]
category: [ Blog ]
---

I've been using `git range-diff` for the past few months to explain changes
between versions of a patch series, such as different versions of a branch after
responding to review comments on a Pull Request. This post explains how I use
post the output for Markdown-ish consumption on GitHub.

## Primer

If you didn't know, `git range-diff` is the standard way in Git to document
changes between versions of a patch series such as you might find sent to a
development mailing list. For example, `git format-patch` can include it
automatically in the email so that, when responding to review comments with a
new version, reviewers understand what's changed.

This all seems only relevant to email-driven workflows, but I argue that it is
also useful for GitHub- or other web- driven workflows. For example: I work on a
branch and submit a Pull Request on GitHub. After some review comments, I may
create some `--fixup` commits and `rebase --autosquash` them in, perhaps editing
commit messages, or make any number of other changes. When the time comes to
`push --force-with-lease --force-if-includes`, the only recourse my reviewers
have to understand the changes is GitHub's "View changes" button, which attempts
a textual diff between the files at the old and new branch tip.

Yet a range-diff can capture so much more! Consider, for example, this
range-diff from a Racket PR I submitted:

```
1:  907d3ea366 = 1:  35c19f1e83 docs: capitalize the noun Git
2:  665e037505 ! 2:  6088cd1567 docs: mention the Vi command to add sections
    @@ pkgs/racket-doc/scribblings/style/textual.scrbl: read code on monitors that acco
     +So, when you create a file, add a line with @litchar{;; } followed by ctrl-U 99
     +and @litchar{-}. @margin-note*{In Vi, the command is 99a- followed by Esc.} When
     +you separate "sections" of code in a file, insert the same line. These lines
    -+help both writers and readers to orient themselves in a file. In scribble use
    ++help both writers and readers to orient themselves in a file. In Scribble use
     +@litchar|{@; }| as the prefix.

      @; -----------------------------------------------------------------------------
3:  808676897e = 3:  1e7b35da0a docs: link fx+ and unsafe-fx+
4:  ca7d2a2a56 = 4:  c3e32a5afa docs: correct Git pull command
5:  1108c95343 = 5:  372bbd4ad5 docs: unquote "merge commit"
6:  1374b3b095 < -:  ---------- docs: italicize "e.g."
7:  8f3f1cd517 = 6:  e48525eeb7 docs: correct macro body
-:  ---------- > 7:  38b3c0a75e docs: make explicit the convention for Latin
```

GitHub won't show you this difference: I capitalized a word in an old commit
message, removed the commit that italicized Latin abbreviations and added one
that clarified said convention. I prefer to provide my reviewers with this
information to help them understand the changes I've made (and to help future
readers who may be curious, though I admit this is unlikely in most cases).

## Sharing a range-diff in Markdown format

A range-diff can get quite large if there are substantial code
changes---arguably, the patch series should become a new branch/PR at such a
point, but that is not often how things operate in practice. I used to paste
range-diffs in code blocks like you see above, but with length and GitHub's
comment/review interface they became unwieldy.

Instead, I've started pasting them inside an HTML `details` block so that they
may be collapsed, summarized, and expanded as desired. I often did this by hand,
but [here's the script I now use called `copy-range-diff`](https://github.com/benknoble/Dotfiles/blob/master/links/bin/copy-range-diff):

```
#! /bin/sh

{
  printf '%s\n' '<details><summary>range-diff:</summary>' '' '```'
  cat
  printf '%s\n' '```' '' '</details>'
} | pbcopy
```

This script reads standard in and pipes a modified version of it to a clipboard
command (Linux users probably prefer an `xsel` variant). Placed on the clipboard
after `git range-diff … | copy-range-diff` is an HTML `details` block containing
a Markdown code-fence which is easy to paste into GitHub or similar interfaces.
Sometimes I will add a short summary to the summary tag; other times, I leave
just the mention of a range-diff.

A small tweak should work for pure HTML output so that instead of triple-tick
Markdown fences we emit `<pre>` tags.

<details><summary>Here's the earlier range-diff, in a details block</summary>

<!-- For some reason, Jekyll doesn't know how to process Markdown fences here,
     so trick it with HTML. -->

<pre class="highlight">
<code>1:  907d3ea366 = 1:  35c19f1e83 docs: capitalize the noun Git
2:  665e037505 ! 2:  6088cd1567 docs: mention the Vi command to add sections
    @@ pkgs/racket-doc/scribblings/style/textual.scrbl: read code on monitors that acco
     +So, when you create a file, add a line with @litchar{;; } followed by ctrl-U 99
     +and @litchar{-}. @margin-note*{In Vi, the command is 99a- followed by Esc.} When
     +you separate "sections" of code in a file, insert the same line. These lines
    -+help both writers and readers to orient themselves in a file. In scribble use
    ++help both writers and readers to orient themselves in a file. In Scribble use
     +@litchar|{@; }| as the prefix.

      @; -----------------------------------------------------------------------------
3:  808676897e = 3:  1e7b35da0a docs: link fx+ and unsafe-fx+
4:  ca7d2a2a56 = 4:  c3e32a5afa docs: correct Git pull command
5:  1108c95343 = 5:  372bbd4ad5 docs: unquote "merge commit"
6:  1374b3b095 < -:  ---------- docs: italicize "e.g."
7:  8f3f1cd517 = 6:  e48525eeb7 docs: correct macro body
-:  ---------- > 7:  38b3c0a75e docs: make explicit the convention for Latin</code>
</pre>

</details>
