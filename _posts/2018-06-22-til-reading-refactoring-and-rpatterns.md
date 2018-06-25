---
title: Reading, Refactoring, and RPatterns
tags: [ til, infra, intern, refactor, shell ]
category: Work
---

I couldn't leave the alliteration hanging in a title containing the word
'patterns'...

# Today I Learned

1. I was not alone in the [IXIA][] troubles
2. Reading build logs hurts
3. Refactoring without changing the functional result is fun
4. I use the right patterns

## Icky Ixia

I pinged a colleague in our Mountain View office about the Ixia, and he let our
team know that we had done well so far. He had tech support help him when he was
where we are now, and he got us rolling with them.

Progress is being made.

On that note, I'd like to add that my colleague [Merit McMannis][] was very
pleased with my contributions to the Ixia.

But then, I was pulled off of that and put on...

## Build Times

Let me just say one thing about builds, their scripts, and their logs. I expect
to be able to jump into a build and know what's going on at a high level,
even if I don't know the gory details.

This means that

1. A build should be composed of understandable steps *on a high level*, like a
recipe
2. Build scripts should reflect *on a high level* those steps
3. Logs should output what step is being performed, what actions compose that
step, and failures/failure points if any

We can solve 2 with well-refactored scripts, using function names as high- (and
low-) level components. We can actually solve 3 with this as well: all of my
bash scripts start with something like this--

```bash
log() {
  printf '%s\n' "$@" # >&2 # stderr variant
  # variant with script name:
  printf "$0: "'%s\n' "$@"
}
```

It helps me output simple information when I need it. But we also have to be
choosy about what information that is! (If I have to scan through the output of
another `./configure --whatever --feature=foobar`, I might go mad).

Reflecting 1 in all of this means documentation and a clear understanding of
what the process is--in fact, this necessitates 2 and 3 be solved already.

I'm dissecting this today because I have been reassigned to work on improving a
build time. Apparently, someone's feature merge caused a 3x increase in
time-to-build. We suspect there's a duplicate compilation going on, and we'd
like to turn that into a make target to do it in parallel, but we can't find it.

Or, well, *I* can't find it. I sifted through a bajillion line error log,
knowing already at least what script was the primary builder and what portions
of that were possibly causing the problem. I couldn't find it, between the
`configure` output, `make` output, errors that get thrown away, and just general
lack of informative detail.

I'm sure the information is useful to someone, somewhere. For me, though, not so
much. Part of the output was a bash script being run in debug mode (`set -x`)!

Fortunately, I have free reign to refactor in an effort to diagnose and solve
the issue. It might kill the `git blame` a little bit, but *dang* does that code
look cleaner.

## Functional Refactoring

My definition of functional refactoring is

> Refactoring which doesn't alter the function

That is, changing

```bash
if [ $var -eq true ]
then
# do a thing
sed 's/func/function' /really/long/file/name
cp /really/long/file/name /other/name
fi

```

to the equivalent

```bash
do_a_thing() {
  local source=/really/long/file/name
  local dest=/other/name
  local sub='s/func/function'
  sed "$sub" "$source"
  cp "$source" "$dest"

main() {
  if [[ "$var" = true ]]; then
    do_a_thing
  fi
}

main
```

is a valid refactoring. I do this all the time because it helps me pull blocks
of code into functions. I even turn developer comments into function names when
I don't know what the code does or why. Theoretically, this is all purely
mechanical, it shouldn't change the net result.

So, I did that all day today. It's funny how much better things read that way.

## Patterns Patterns Patterns

Not much to say here, just a quote from the colleague who assigned me this task:

> there's a lot of 'crufty' code here, and based on your coding exercise, you
> have proper patterns ingrained already
>
> (and reducing build times by 3x is a super awesome project, imo)
>
> well, maybe not quite 3x reduction...but we can round up :wink:

So I'd say my first week finished strong.

[IXIA]: {% link _posts/2018-06-18-til-first-day.md %}
[Merit McMannis]: https://www.linkedin.com/in/meritmcmannis/
