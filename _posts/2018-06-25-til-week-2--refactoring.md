---
title: Week 2--Refactoring++
tags: [ til, infra, intern, refactor ]
category: Work
---

Something about those [R][]'s keeps coming back...

# Today I Learned

1. What a DHCP cluster is
2. We all make copy/paste/complete errors
3. Intuition is a strong indicator

## DHCP Clustering

I had some spare cycles today while waiting for a build (more on that in a
moment), so I checked in with a colleague to see what else I could take on as a
spare-time task. He assigned me to "cluster the DHCP server so that, in case of
failure, we have a backup." Sounds straightforward.

It's not.

A DHCP cluster is effectively two DHCP servers that are tied together to act as
one DHCP. They can do this by sharing the load for incoming traffic or by having
one be dominant, with the other spinning up when the dominant one goes down.

What complicates our setup (beyond this being a complex task) is that our DHCP
is actually a VM. So, to get this thing working, I'll need to spin up a new VM
running the same image, configure it on the network, and then "cluster" them
(whatever that entails).

My spare cycles were spent on researching this to have a plan before-hand. I
still don't have said plan.

## Copy/Paste Errors & Complete Fools

Every coder makes a copy/paste error at least once in their life. Good
developers try to mitigate the effects of this with tests. Strong developers
seek to reduce duplicated code (or code differing by only a few pieces) to avoid
it all together.

If you don't know what a copy/paste error is, it goes something like this. I've
got this code for e.g. multiplication:

```python
def mult(a, b):
  result = a * b
  return result
```

And now I have to do division, so I copy/paste the block somewhere else. Only I
forget to change it:

```python
# spot the error
def div(a, b):
  result = a * b
  return result
```

The `result` ? Anything from a broken build to people dying. Yes, you read that
right, *death*. Think about a hospital or other missions-critical system.
Granted, that code *better* get tested, but what if the error occurs in your
tests? Then you're really stuck.

### Relevance

Today, I was a "complete fool." I didn't actually make a copy/paste error--thank
goodness. I spent most of my time, as I did Friday, refactoring code and
eliminating precisely the kind of duplicate code that goes hand-in-hand with
copy/paste errors.

But I did make two mistakes that were agonizingly difficult to track down.

And it's because of one of my favorite [vim][] features: auto-complete.

The first one goes like this. I have some shell script to fixup some files and
then copy them to specific spots, so that a later build step will find it.
Something like

```bash
version_and_copy_single_file() {
  local source="$1"
  local dest="$1"
  sed -e 's/good/bad' "$source"
  cp "$source" "$dest"
}

version_and_copy_files() {
  # [source]=dest
  local -A files=(
    [foo]=bar
    [zork]=grue
    #...&c.
  )

  for source in "${!files[@]}" ; do
    local dest="${files["$source"]}"
    version_and_copy_single_file "$source" "$dest"
  done
}
```

Nice, clean, functionally extracted, I even used an associative array, one of my
favorite ways to tie data together in bash.

But there's a problem. The `dest` parameter isn't set right. It should be the
second, not the first, so the copying wasn't actually working. All because I
completed the end of the line wrong, using the line above as context. The fix
was `local dest="$2"` in the single file function. Might as well have been
copy/paste, for the single bit of difference that broke my build.

Number two is even better.

Essentially, `rpmbuild` is a binary that gets called to build rpm image files.
And our builds have to make a certain subset depending on parameters. So I took
the build logic and gave each one its own function, then did the same for the
logic that decided which ones to build.

The problem? My 'decide which to build' function was named `rpmbuilder`. So when
I autocompleted `rpmbuild --params` as `rpmbuilder --params` without a second
thought, I caused an hour-wasting recursion. Each recursive call built rpm
images and then asked for more. Deadly. Now you know why I had spare cycles.

The best fix in this case was prevent anyone from doing that by giving the
function name something crazy: `actually_build_rpms`. Can't mistake that.

### Intuition

I only found this because a build that takes 20 minutes usually suddenly lasted
an hour. I suspected during the first half something was wrong, but I was
certain by the end of an hour. And because I smartly logged everything I was
doing, I was able to track the same line being output over and over and over.

All because my gut said--this is broke.

# Conclusion ?

Be careful what you type, I guess. But have good tests and a good gut to help
you anyways.

[R]: {% link _posts/2018-06-22-til-reading-refactoring-and-rpatterns.md %}
[vim]: https://www.vim.org
