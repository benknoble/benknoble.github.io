---
title: 'Efficient Shell—Git Commit Statistics'
tags: [dotfiles, git, shell, performance, refactor]
category: Blog
---

I convert a unusably slow script to a surprisingly fast tool.

> Background: any program (script or compiled binary) named `git-*` in your `PATH`
> can be run like a git sub-command. See `man git-sh-setup` for some utility
> functions for scripts.

## Meet `git-cstat`

[This little
script](https://github.com/benknoble/Dotfiles/commit/f7657493f61b449b2b27ceb8f4e24f2dfb43e71c)
has been in my bin directory since September of 2018. In it's initial
conception, it counted commits and the lengths of their messages before
displaying a report (count, min, max, avg). It had noisy output, and it took
ages to run on my Dotfiles, but it worked.

It underwent some revisions, such as [calculating the average more
precisely](https://github.com/benknoble/Dotfiles/commit/550db2969a304b30ce199ec2d35c3bb1bf605e72#diff-aab6845f62898d4a22e2bab872fbd33e).

And then, [when I added
`git-mstat`](https://github.com/benknoble/Dotfiles/commit/3af2ba76708f308bfa70e3348629740c02e495ce),
I decided the interface needed an update.

## Improvements

First, I wanted the [`mstat` style
interface](https://github.com/benknoble/Dotfiles/commit/cb0c865272d06fce3f1471f798de0bd214ae9c57):
tell `cstat` to give you the `count`, or `len max`, and it will (with a minimum
of output noise).

Then, I wanted the damn thing to be usable. This was a statistic tool, and
could be useful for reflection. Waiting around for seconds (an eternity at the
command line for a power user like me) was not going to cut it.

### On Efficient Shell

The essence of efficient shell is efficient pipelines: do as much as possible in
programs designed to work for you. Shell is slow.

The humongous algorithm duplication between min and max (and even some in
avg) was really bugging me. So I tried to go from for loops to a more idiomatic
pipeline: sort the data and grab the relevant info. The max is always the top of
the sort, while the min is always the top of a reverse sort.

That was yesterday. With the performance still unfeasible, I knew it was time
for a [code review
(spoilers!)](https://codereview.stackexchange.com/q/226071/123233).

The next work is mostly in [this
merge](https://github.com/benknoble/Dotfiles/commit/e7cebfbe37c1fcb5fe090763491f5c1dfdb5fcf8).

#### Awk

The first task was [converting `len avg` to pure
`awk(1)`](https://github.com/benknoble/Dotfiles/commit/6881e59714263c9abb50e749e4eddac40aa285ab).
This was easy given the output format of `commits_len`: I even used a sample
from the man page. This sped up my averaging, but `commits_len` was still too
slow.

#### Git can count

I then managed to convert my count implementation (already fast) to something
even faster: [pure
git](https://github.com/benknoble/Dotfiles/commit/9d357bf6987e2ba40f56b3f8e0a86143e22cece5).

#### More awk

By then I knew I needed to fix the commit length stuff. It was the bottleneck,
and I'd convinced myself I couldn't fix it. But it was time.

I *knew* that if there was an efficient way to output lines of `length commit`
straight using a couple of tools, without forcing consumers to do their own
looping and sizing, the problem would be solved. Consumers would just be simple
`sort(1)`/`head(1)`/`awk(1)` pipelines.

And I banged my head on this wall for *hours*.

As is usually case, it's all about having your data in the right format. I knew
with `git-log` I could grab all the commits and their messages (thanks,
`--pretty`). But I would need to process that, and quickly. The biggest issue
was their was no clear "end of record" marker for a tool like awk to use: how
did I know when a new commit began?

Worse, the null-byte (my favorite data-delimiter for scripts) was out: awk was
really having a hard time with the pattern `$'/\x00/'`.

Finally, I got creative: I embedded a control character (the beep sequence,
actually, sometimes known as <kbd>Ctrl</kbd>-<kbd>G</kbd>) at the start of each
record. Then I could use awk, with a tab between commit hash and message body,
to join all the lines of the message.

> Aside: coming to this was basically hours of playing with a live terminal. I
> composed pipelines until my head hurt and the screen-wrap was unreadable. But
> it did work in the end. At the end I've posted a *sample* of my bash history,
> so you can see what I was working with.

With the data in that format, counting became easy. I could just split the
second field.

[And that's exactly what I
did](https://github.com/benknoble/Dotfiles/commit/62cada2e5af667195029d856005457ceed323a64).

### Clean up

I did have to [fix a few things
post-merge](https://github.com/benknoble/Dotfiles/commit/b9de715e0fd87c83e0aa796d597571a5a71006d7),
but overall this was a huge success. The old script ran in 10s of seconds on my
Dotfiles repo. The new one runs in less than 0.5 seconds.

---

Things to know:

- `alias g=git`
- `alias.s = status -sb`
- `alias.d = diff`
- `v() { vim "$@" ; }`
- `G() { grep "$@" ; }`
- `L() { less "$@" ; }`

Bash history excerpt:

```bash
g log --pretty=format:'%H %B' --max-count=1 --all
g log --pretty=format:'%H %B' --max-count=h5 --all
g log --pretty=format:'%H%x00 %B' --max-count=5 --all
g log --pretty=format:'%H %s %b' --max-count=h5 --all
g log --pretty=format:'%H %s %b' --max-count=5 --all
g log --pretty=format:$'%H\t%s %b' --max-count=5 --all
g log --pretty=format:$'%H\t%s %b' --max-count=5 --all | awk '{print $2}'
g log --pretty=format:$'%H\t%s %b' --max-count=5 --all | awk -F$'\t' '{print $2}'
g cstat len | L
g cstat len | L
g cstat len | L
g log --pretty=format:$'%H\t%s %b' --all | awk -F$'\t' '{print $2}'
g log --pretty=format:$'%H\t%s %b' --all | awk -F$'\t' '{print $1}' |L
g log --pretty=format:$'%H\t%s %b' --all |L
g log --pretty=format:$'%H\t%s %b' --all |L
v <(g log --pretty=format:$'%H\t%s %b' --all)
g cstat len avg
g cstat len max
g cstat len min
git log -1 @ --format=%B
git log -1 @ --format='%s %b'
git log -1 @ --format='%s %b' |L
git log --format='%s %b' |L
git log --format='%h %s %b' |L
git log -1 fd1a510 --format='%s %b' |L
git log -1 fd1a510 --format='%s %b'
git log -1 fd1a510 --format='%s %B'
git log -1 fd1a510 --format='%s %b%x00'
g cstat len
g cstat len
g cstat len | L
g log --pretty=format:$'%H\t%s %b%x00' | L
g log --pretty=format:$'%H\t%s %b%x00' | awk 'END { print NR }'
g log --pretty=format:$'%H\t%s %b%x00' | awk -v RS=$'\0' 'END { print NR }'
g log --pretty=format:$'hash%H\t%s %b%'
g log --pretty=format:$'hash%H\t%s %b%' | G -v '^hash'
g log --pretty=format:$'hash%H\t%s %b' | G -v '^hash'
g log --pretty=format:$'\0\t%H\t%s %b' | sed $'/\0/,/\0/-1 s /\\n//'
g log --pretty=format:$'\a\t%H\t%s %b' | sed $'/\a/,/\ja/-1 s /\\n//'
printf '%s\n' a b a
printf '%s\n' a b a | awk '/a/,/a/-1'
printf '%s\n' a b a | awk '/a/,/a/'
printf '%s\n' a b a | awk '/a/+1,/a/'
printf '%s\n' a b a | awk '/a/,-1/a/'
printf '%s\n' a b a | awk '/a/+1,/a/-1'
printf '%s\n' a b a | awk '/a/+1,/a/-1 { print sub('\n', '') }'
printf '%s\n' a b a | awk '/a/+1,/a/-1 { print sub("\n", "") }'
printf '%s\n' a b a | awk '/a/+1,/a/-1 { sub("\n", "");print }'
printf '%s\n' a b a | awk '/a/+1,/a/-1 { sub("\n", "a");print }'
printf '%s\n' a b a | awk '/a/+1,/a/-1 { sub("\\n", "a");print }'
printf '%s\n' a b a | awk $'/a/+1,/a/-1 { sub("\n", "a");print }'
printf '%s\n' a b a | awk $'/a/+1,/a/-1 { sub("\\n", "a");print }'
printf '%s\n' a b a | awk '/a/+1,/a/-1 { sub("\n", "a");print }'
printf '%s\n' a b a | awk '/a/+1,/a/-1 { sub("\n", "a");printf '%s' $0 }'
printf '%s\n' a b a | awk '/a/+1,/a/-1 { sub("\n", "a");printf "%s" $0 }'
printf '%s\n' a b a | awk '/a/+1,/a/-1 { sub("\n", "a");printf "%s", $0 }'
g log --pretty=format:$'\a\t%H\t%s %b' | sed '/\a/{n;:l N;/\a/b; s/\n//; bl}' input
g log --pretty=format:$'\0\t%H\t%s %b' | sed '/\0/{n;:l N;/\0/b; s/\n//; bl}' input
g log --pretty=format:$'\0\t%H\t%s %b' | sed '/\0/{n;:l N;/\0/b; s/\\n//; bl}' input
g log --pretty=format:$'\0\t%H\t%s %b' | awk '/HEADER/ {printf "\n%s\n",$0;next} {printf "%s ",$0}'
g log --pretty=format:$'\0\t%H\t%s %b' | awk '/\0/ {printf "\n%s\n",$0;next} {printf "%s ",$0}'
g log --pretty=format:$'\0\t%H\t%s %b' | awk '/\0/ {printf "\n%s\n",$0;next} {printf "%s ",$0}'
g log --pretty=format:$'\0\t%H\t%s %b' | awk '/\0/ {printf "\n%s\n",$0;next} {printf "%s ",$0}' | L
g log --pretty=format:$'\a\t%H\t%s %b' | awk '/\a/ {printf "\n%s\n",$0;next} {printf "%s ",$0}' | L
g log --pretty=format:$'\a\t%H\t%s %b' | awk '/\a/ {printf "\n%s\n",$0;next} {printf "%s ",$0}' | L
g log --pretty=format:$'HEADER%n\t%H\t%s %b' | awk '/HEADER/ {printf "\n%s\n",$0;next} {printf "%s ",$0}' | L
v <(g log --pretty=format:$'HEADER%n\t%H\t%s %b' | awk '/HEADER/ {printf "\n%s\n",$0;next} {printf "%s ",$0}')
v <(g log --pretty=format:$'HEADER%n\t%H\t%s %b' | awk '/HEADER/ {printf "\n%s\n",$0;next} {printf "%s ",$0}')
v <(g log --pretty=format:$'HEADER%n\t%H\t%s %b' | awk '/HEADER/ {next} {printf "%s ",$0}')
v <(g log --pretty=format:$'HEADER%n\t%H\t%s %b' | awk '/HEADER/ {printf "\n"; next} {printf "%s ",$0}')
v <(g log --pretty=format:$'HEADER%n%H\t%s %b' | awk '/HEADER/ {printf "\n"; next} {printf "%s ",$0}')
g log --pretty=format:$'HEADER%n%H\t%s %b' | awk '/HEADER/ {printf "\n"; next} {printf "%s ",$0}' | wc -l
g rev-list --count
g rev-list --count --all
g log --pretty=format:$'HEADER%n%H\t%s %b' | awk '/HEADER/ {printf "\n"; next} {printf "%s ",$0}' | wc -l
g log --pretty=format:$'\a%n%H\t%s %b' | awk '/\a/ {printf "\n"; next} {printf "%s ",$0}' | wc -l
g log --pretty=format:$'HEADER%n%H\t%s %b' | awk '/HEADER/ {printf "\n"; next} {printf "%s ",$0}' | wc -l
g s
g d
g log --pretty=format:$'HEADER%n%H\t%s %b' | awk '/HEADER/ {printf "\n"; next} {printf "%s ",$0}' | wc -l
g log --pretty=format:$'%x00%n%H\t%s %b' | awk '/\x0/ {printf "\n"; next} {printf "%s ",$0}' | wc -l
g log --pretty=format:$'%x00%n%H\t%s %b' | awk '/\x0/ {printf "\n"; next} {printf "%s ",$0}' | L
g log --pretty=format:$'%x00%n%H\t%s %b' 
g log --pretty=format:$'%x00%n%H\t%s %b' | awk '/\x0/ {printf "\n"; next} {printf "%s ",$0}'
g log --pretty=format:$'HEADER%n%H\t%s %b' | awk '/HEADER/ {printf "\n"; next} {printf "%s ",$0}' | wc -l
g log --pretty=format:$'%n%n%H\t%s %b' | awk '/^$/ {printf "\n"; next} {printf "%s ",$0}' | wc -l
g log --pretty=format:$'HEADER%n%H\t%s %b' | awk '/HEADER/ {printf "\n"; next} {printf "%s ",$0}' | wc -l
g log --pretty=format:$'%x00%n%H\t%s %b' | awk '/\x0/ {printf "\n"; next} {printf "%s ",$0}' | L
g log --pretty=format:$'%x00%n%H\t%s %b' | awk '/\x0/ {printf "\n"; next} {printf "%s ",$0}' | cat -enb | L
g log --pretty=format:$'%x00%n%H\t%s %b' | awk '/\xx0/ {printf "\n"; next} {printf "%s ",$0}' | cat -enb | L
g log --pretty=format:$'%x00%n%H\t%s %b' | awk '/\xx0/ {printf "\n"; next} {printf "%s ",$0}' | L
g log --pretty=format:$'%x00%n%H\t%s %b' | awk '/\xx00/ {printf "\n"; next} {printf "%s ",$0}' | L
g log --pretty=format:$'%x00%n%H\t%s %b' | awk '/\xx00/ {printf "\n"; next} {printf "%s ",$0}' | wc -l
g log --pretty=format:$'%x00%n%H\t%s %b' | awk '/\xx00/ {printf "\n"; next} {printf "%s ",$0} END {printf "\n"}' | wc -l
g log --pretty=format:$'%x00%n%H\t%s %b' | awk '/\xx00/ {printf "\n"; next} {printf "%s ",$0}' | wc -l
printf '%s\n' $'\0abc' def
printf '%s\n' $'a\0bc' def
printf '%s\n' $'a\abc' def
printf '%s\n' $'a\abc' def | awk '/\a/'
printf '%s\n' $'a\abc' def | awk '/\x0a/'
printf '%s\n' $'a\abc' def | awk '/\xa/'
printf '%s\n' $'a\abc' def | awk '/\xxa/'
printf '%s\n' $'a\abc' def | awk '/\a/'
printf '%s\n' $'\abc' def | awk '/\a/'
printf '%s\n' $'\abc' def | awk $'/\a/'
g log --pretty=format:$'\a%n%H\t%s %b' | awk $'/\a/ {printf "\n"; next} {printf "%s ",$0}' | wc -l
g log --pretty=format:$'\a%n%H\t%s %b' | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | wc -l
g cstat count
g cstat len
g cstat len |L
g cstat len >/dev/null
g log --pretty=format:$'\a%n%H\t%s %b' | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' |L
g log --pretty=format:$'\a%n%H\t%s %b' | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' |cat -enb|L
man cat
g log --pretty=format:$'\a%n%H\t%s %b' | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' |cat -venb|L
g log --pretty=format:$'\a%n%H\t%s %b' | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' |cat -tvenb|L
g log --pretty=format:$'\a%n%H\t%s %b' | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' |cat -tveb|L
g log --pretty=format:$'\a%n%H\t%s %b' | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' |cat -tveb|L
g log --pretty=format:$'\a%n%H\t%s %b' | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print length($2), $1}'
g log --pretty=format:$'\a%n%H\t%s %b' --all | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print length($2), $1}'
g log --pretty=format:$'\a%n%H\t%s %b' --all | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print length($2), $1}' | sort -rn | head -1
g log --pretty=format:$'\a%n%H\t%s %b' --all | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print length($2), $1}' | sort -rn | head -1 | awk '{print $2 }' | xargs git show
g log --pretty=format:$'\a%n%H\t%s %b' --all | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print length($2), $1}'
g log --pretty=format:$'\a%n%H\t%s %b' --all | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,a), $1}'
g log --pretty=format:$'\a%n%H\t%s %b' --all | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,a), $1}' | sort -rn | head -1 
g log --pretty=format:$'\a%n%H\t%s %b' --all | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,a,' '), $1}' | sort -rn | head -1 
g log --pretty=format:$'\a%n%H\t%s %b' --all | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,a," "), $1}' | sort -rn | head -1 
g log --pretty=format:$'\a%n%H\t%s %b' --all | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,a," "), $1}' | sort -rn | head -1 | awk '{print $2 }' | xargs git show
g log --pretty=format:$'\a%n%H\t%s %b' --all | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,a," "), $1}' | sort -rn | head -1 
g log --pretty=format:$'\a%n%H\t%s %b' --all | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,a," "), $1}' | sort -n | head -1 
g log --pretty=format:$'\a%n%H\t%s %b' --all | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,a," "), $1}' | G 0
g log --pretty=format:$'\a%n%H\t%s %b' --all | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,a," "), $1}' | G ^0
g log --pretty=format:$'\a%n%H\t%s %b' --all | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,a," "), $1}' | head -1
g log --pretty=format:$'\a%n%H\t%s %b' --all | awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,_," "), $1}' | head -1
g log --pretty=format:$'\a%n%H\t%s %b' --all | G -v '^$' awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,_," "), $1}' | head -1
g log --pretty=format:$'\a%n%H\t%s %b' --all | G -v '^$' |awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,_," "), $1}' | head -1
g log --pretty=format:$'\a%n%H\t%s %b' --all |awk '/'$'\a''/ {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,_," "), $1}' | head -1
g log --pretty=format:$'\a%n%H\t%s %b' --all |awk '/'$'\a''/ && NR != {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,_," "), $1}' | head -1
g log --pretty=format:$'\a%n%H\t%s %b' --all |awk '/'$'\a''/ && NR != 1 {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,_," "), $1}' | head -1
g log --pretty=format:$'\a%n%H\t%s %b' --all |awk '/'$'\a''/ && NR != 1 {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,_," "), $1}' | sort -n | head -1
g log --pretty=format:$'\a%n%H\t%s %b' --all |awk '/'$'\a''/ && NR != 1 {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,_," "), $1}' | G '^0'
g log --pretty=format:$'\a%n%H\t%s %b' --all |awk '/'$'\a''/ && NR != 1 {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,_," "), $1}'
g log --pretty=format:$'\a%n%H\t%s %b' --all |awk '/'$'\a''/ && NR != 1 {printf "\n"; next} {printf "%s ",$0}' | awk -F$'\t' '{print split($2,_," "), $1}'
g log --pretty=format:$'\a%n%H\t%s %b' --all |awk '/'$'\a''/ && NR != 1 {printf "\n"; next} {printf "%s ",$0}' | wc -l
g log --pretty=format:$'\a%n%H\t%s %b' --all |awk '/'$'\a''/ && NR != 1 {printf "\n"; next} {printf "%s ",$0} END{print}' | wc -l
g log --pretty=format:$'\a%n%H\t%s %b' --all |awk '/'$'\a''/ && NR != 1 {printf "\n"; next} {printf "%s ",$0} END{print}'| L
g log --pretty=format:$'\a%n%H\t%s %b' --all |awk '/'$'\a''/ && NR != 1 {printf "\n"; next} {printf "%s ",$0} END{printf "\n"}'| L
g log --pretty=format:$'\a%n%H\t%s %b' --all |awk '/'$'\a''/ && NR != 1 {printf "\n"; next} {printf "%s ",$0} END{printf "\n"}'|wc -l
```
