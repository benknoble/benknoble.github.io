---
title: 'Commit subject case in Git history'
tags: [ git, statistics ]
category: [ Blog ]
---

[Some insist that commit subjects be
capitalized](https://cbea.ms/git-commit/#capitalize). Does this actually happen
in practice?

Here's a quick analysis of the Git source repository (see [my fields script]({%
link _posts/2019-09-11-fields.md %}) or [use your own]({% link
_posts/2024-11-15-useful-utilities.md %}#parallel-thoughts)):

```shell
git log --oneline --no-decorate | fields 2 |
    tee >(grep -c '^[[:lower:]]' >lower) >(grep -c '^[[:upper:]]' >upper) >/dev/null
diff -y lower upper
# => 44019 | 30636
```

Looks roughly even, with a slight preference for lower case words (~59%). But if
we filter out automatic messages from merges and reverts:

```shell
git log --oneline --no-decorate | fields 2 |
    tee >(grep -c '^[[:lower:]]' >lower) \
      >(grep -v -e Merge -e Revert | grep -c '^[[:upper:]]' >upper) >/dev/null
diff -y lower upper
# => 44019 | 11423
```

Well, that's just above 79% preference for lowercase.

Measurements taken from the branch I happened to be on, which is [daee763610
(completion: repair config completion for Zsh,
2024-12-29)](https://github.com/benknoble/git/commit/daee7636106ecf9a7eb445038bf87348e0105478).

Note that the total from the first report (74655) undercounts the number of
commits by about 1109 according to `git rev-list --count HEAD`. This is exactly
the number of commits output by

```shell
git log --oneline --no-decorate | fields 2 | grep -cv -e '^[[:lower:]]' -e '^[[:upper:]]'
```

Here's a histogram of the starts that got omitted by my simple measure (remove
`-c` on the previous `grep` and pipe to `sort | uniq -c | sort -rn`):

```
 892 [PATCH]
  36 .mailmap:
  19 [PATCH
  14 "git
  12 .gitignore:
   9 .gitattributes:
   4 __attribute__:
   4 2.36
   4 *:
   3 [patch]
   3 .mailmap
   3 --walk-reflogs:
   3 --pretty=format:
   3 *.sh:
   3 *.h:
   3 *.c
   3 *.[ch]:
   3 'git
   3 "log
   3 "Assume
   2 {fetch,upload}-pack:
   2 0th
   2 -u
   2 --dirstat:
   2 *.[ch]
   2 (trivial)
   2 $EMAIL
   2 "remote
   2 "rebase
   2 "make
   1 {upload,receive}-pack
   1 {reset,merge}:
   1 {lock,commit,rollback}_packed_refs():
   1 {cvs,svn}import:
   1 {builtin/*,repository}.c:
   1 `git
   1 _XOPEN_SOURCE
   1 _GIT_INDEX_OUTPUT:
   1 \n
   1 [fr]
   1 ?alloc:
   1 3%
   1 2.3.2
   1 .gitignore
   1 .github/workflows/main.yml:
   1 .github/PULL_REQUEST_TEMPLATE.md:
   1 ./configure.ac:
   1 -Wuninitialized:
   1 -Wold-style-definition
   1 --utf8
   1 --summary
   1 --prune
   1 --name-only,
   1 --format=pretty:
   1 --dirstat-by-file:
   1 --base-path-relaxed
   1 *config.txt:
   1 *.h
   1 (various):
   1 (squash)
   1 (short)
   1 (revert
   1 (encode_85,
   1 (cvs|svn)import:
   1 (Hopefully)
   1 'make
   1 'git-merge':
   1 'build'
   1 $GIT_COMMON_DIR:
   1 "test"
   1 "reset
   1 "needs
   1 "lib-diff"
   1 "init-db"
   1 "git-tag
   1 "git-push
   1 "git-merge":
   1 "git-fetch
   1 "git-apply
   1 "git-add
   1 "git"
   1 "format-patch
   1 "diff
   1 "current_exec_path"
   1 "core.sharedrepository
   1 "color.diff
   1 "checkout
   1 "branch
   1 "blame
   1 "assume
   1 "add
   1 
```

Just for kicks, if I try the _2nd_ word of the commit message in those cases:

```shell
git log --oneline --no-decorate | fields 2 3 |
    grep -v -e '^[[:lower:]]' -e '^[[:upper:]]' | fields 2 |
    tee >(grep -c '^[[:lower:]]' >lower) >(grep -c '^[[:upper:]]' >upper) >/dev/null
diff -y lower upper
# => 491 | 567
```

We're still undercounting by 51, but the above doesn't modify our results much
(essentially still within the rounding I used). The 51 commits ought to be in
the noise. Even attributing them all as upper case, the rounded percentages
don't change.
