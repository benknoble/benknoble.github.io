---
title: 'Making mass-edits to many repos via shell pipelines'
tags: [ dotfiles, git, github, github-workflow, json, productivity, project-management, shell, ]
category: [ Blog ]
---

I spend 1 day to save 3 immediately, and more long-term, by scripting git into
pipelines.

## Prelude

Imagine you have a task before you that requires you to update 15 or so
repositories on GitHub with the same or similar one-line changes in several
different files. How do you solve it?

In my case, I had a list of 16 repository URLs in the file `URLs`; I collected
these after figuring out which YAML variables to correct in order to fix an
installation problem with a part of our infrastructure. And I knew I could clone
them all, fork them, do the changes, and open the pull-requests, but it would
take forever! Too many manual steps.

So I got clever.

> If you aren't sure how `xargs` works, you will be by the end of this post:
> `xargs` is a filter that takes its standard in and uses it as arguments for
> another command. In essence, it can replace `while read` loops, when used
> right.

## Kitchen Cutlery---or rather---Forks

My first step was to figure out how to fork all those repos! I knew about `hub
fork`, but it only works from inside an already cloned repo. Then there's the
new GitHub CLI `gh repo fork`, but it doesn't support enterprise GitHub yet.
Darn!

I really wanted to do this separately, so I [whipped up a forking
script](https://github.com/benknoble/Dotfiles/blob/master/links/bin/git-fork-repo).
In the process, I had to learn how to use the GitHub API and [workaround a bug
in hub's `api` command on enterprise
hosts](https://github.com/github/hub/issues/2576). The script outputs the URL of
the fork for downstream consumption (e.g., `open` on a Mac).

After testing the script, I was ready to create all the forks!

Well, not exactly. I designed the script to take parameters `owner repo`, not
URL… it is specific to GitHub, after all. So I needed to transform the URLs. I
probably could have done a combination of `basename` and `dirname`, but for this
task I wrote an `awk` script:

```awk
#! /usr/bin/env awk -f
# mk-forkable.awk

BEGIN { FS="/" }
{ print $4, $5 }
```

This enabled step one, forking:

```bash
<URLs ./mk-forkable.awk | xargs -L1 git fork-repo >forks
```

This gives me a list of fork URLs in `forks` and creates the forks on GitHub.

## Mass changes

And no, I'm not talking about *weight* changes---I mean being able to make
changes to all the repos! What I really wanted, I realized, was the ability to
pipe in the list of repositories to a script that would clone them, make the
changes on a new branch, push that branch, and spit out the repository URL again
so I could open it up.

Thus, [`git-mass-edit` was
born](https://github.com/benknoble/Dotfiles/blob/master/links/bin/git-mass-edit).
The usage really sums up the intended use- and design-case:

```
usage: $0 [-b <branch-name>] [-m <message>] [-r <remote-name>] <edit-command> <repo>
Executes the following steps:
  - If <repo> doesn't exist, clones it
  - Creates a new branch named <branch-name>
  - Runs <edit-command> inside the repo
  - Commits using <message>
  - Pushes to <branch-name> on <remote-name>
  - Outputs <repo>
Default values:
  <branch-name>  mass-edit
  <message>      mass-edit
  <remote-name>  origin
Designed to be attached to xargs(1) and an input stream of repos to mass-edit.
For example, if you have a list of github URLs you want to edit the same way and
then open up in a browser:
<URLs xargs -n1 [-P...] git-mass-edit [...] edit-command | xargs open
```

All that was left was to build an editing script, which mostly delegates to a
silenced and nerfed vim, which uses `git-grep` to build a list of lines to
change and then changes them with `cdo` and `substitute`:

```bash
#! /usr/bin/env bash
# fix-yaml-var

set -euo pipefail

log() {
  printf '%s\n' "$@"
} >&2

die() {
  local ex="${1:-1}"
  exit "$ex"
}

main() {
  git config user.name 'David Knoble'
  git config user.email 'david.knoble@WORK'
  local oldkey=old_key
  local newkey=new_key
  local skip=does-not-exist
  local newval=our-new-val
  vim -es -N -u NONE -i NONE -S <(cat <<DOG
  set hidden
  if !exists(':Cfilter') | packadd cfilter | endif
  let &grepprg = 'git grep -n'
  silent! grep $oldkey
  silent! cdo substitute/$oldkey/$newkey/g
  Cfilter! /$skip/
  Cfilter /$oldkey:/
  silent! cdo substitute^:.*^: $newval^
  wall
  quit
DOG
)
}

main "$@"
```

Finally, I launched the script!

```bash
<forks xargs -n1 -P8  git-mass-edit -b fix-yaml-var -m 'some message' $(realpath ./fix-yaml-var) | xargs -L1  open
```

From here, I did the (very manual) process of opening all the PRs. If I had
been a bit smarter, I would have you used `hub pull-request` with `-F` to do
these, but this might have required additional setup.

## But wait, there's more!

I wanted to collect a list of PRs without trying to webscrape them off my PRs
page. I had the repos, and `hub`'s command `pr` can show the URL. I needed to
do some setup, though, because `hub pr` only works when the remote is the
upstream repository!

First, move the old repos out of the way:

```bash
<forks xargs basename | -n1 bash -c 'mv "$1" benknoble-"$1)"' sh
```

(Thank goodness `basename` works on URLs! Coincidence?)

Next, clone the proper repositories:

```bash
<URLs xargs -L1 -P$(wc -l <URLS) git clone --quiet
```

In parallel, this goes pretty quickly.

Lastly, grab the URLs. Oh, wait, I had to script that too:

```bash
#! /bin/sh
cd "$1" && hub pr show -u "$(hub pr list | grep 'the PR title' | fields 1 | cut -c2-3)"
```

Looking back on it, this only works for 2-digit PR numbers :thinking:

OK, let's actually grab those PR numbers:

```bash
<URLs xargs -L1 basename | xargs -L1 -P$(wc -l <URLs) ./get-pr-url >prs
```

## Addendum

I later had to make some quick fixes, which I did with slightly less up-front
automation work. I had to grab the fixes to be made from PR branches, but
actually make them in the upstream repos in order to pull in the merged changes.
So the first bit was to grab all the right spots and dumps them to the file
fixes:

```bash
<URLs xargs basename | xargs -n1 bash -c 'git -C benknoble-"$1" grep newkey | xargs -L1 echo "$1/"' sh | grep -w cde | sed 's/ //' >fixes
```

Note the nested `xargs` to process the grep results and prepend the repository
name!

I loaded this in vim with the `-q` flag for the quickfix list and made the edit:

```bash
vim -q fixes
# :cdo s/newkey: \zs.*/fixed-value
# :wall | q
```

Then I created a list of repos that needed the fixes using [my old fields
script]({% link _posts/2019-09-11-fields.md %}), and used that to create the
commits. A push to the PR branch and I was good to go.

```
<fixes fields -f: 1 | fields -f/ 1 | sort -u > fixed-repos
<fixed-repos xargs -L1 bash -c 'cd "$1" && git add . && git commit -m "fix the thing"' sh
```
