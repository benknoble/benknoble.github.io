---
title: 'Bisecting for Fun: Finding a Bugfix in Vim'
tags: [ git, bisect, vim ]
category: [ Blog ]
---

I experienced a non-breaking paper cut-style bug in Vim for the last 6 months or
so, and I finally tracked down the details.

## The Bug

I use [ALE](https://github.com/dense-analysis/ale) for linting, and I noticed
that on many files I was getting errors like

```
E219: Function name required
E117: Unknown function: <lambda>54
```

I let it sit for about 6 months, though, because it wasn't stopping me from
getting any work done, and it didn't even seem to be really breaking ALE. It was
disruptive, though.

I finally managed to get a traceback of the bug using `:debug`, but I'll spare
you the details. The end result was an expression like

```vim
" autoload/ale/command.vim
try
    if get(l:result, 'result_callback', v:null) isnot v:null
        call call(l:result.result_callback, [l:value])
    endif
finally
    call ale#command#ResetCwd(a:buffer)
endtry
```

(For the curious: using the pickaxe `-S` for `git log`, I managed to track this
code down to [ALE commit b32fdfe8 (#2132 Implement deferred objects for
ale#command#Run,
2019-02-08)](https://github.com/dense-analysis/ale/commit/b32fdfe8).)

In particular, calling the callback through a capital variable (funcref
requirement) doesn't work, but calling it without `call()` did. Finally, I
managed to simplify the error:

```vim
:echo call({->'foo'}, [])
```

yielded an error!

## The workaround

Well, not being able to `call()` a lambda is a pretty fundamental Vim error for
recent versions of Vim. I happened to be on v9.1.1016, and there had been new
releases, so I figured I'll try the usual advice: upgrade.

Once I upgraded to 9.1.1415 (400 patches later!), the error was gone in my small
repro and in my day to day work. Great!

Now I was curious, though: what happened? When did the bug get introduced, and
when did it get fixed?

## Tracking down the fix

If you know me, this won't surprise you: `git bisect` incoming!

Most uses of bisect are to find the introduction of a bug. Here, though, I had a
broken version and a newer fixed version, so I'm more interested in finding the
_bugfix_. That means the usual `good`/`bad` terms won't be useful here, so I
used `old` (has the bug) and `new` (fixed the bug) in my bisection.

The first thing I did was setup a script to drive the bisection: it needs to
exit 0 if the commit is `old` and non-zero for `new` (except 125 means `skip`).
The script first builds Vim, skipping the commit if it doesn't build:

```shell
./compile || {
  make distclean && ./compile
} || exit 125

# sanity check
test -x src/vim || exit 125
```

(here the `./compile` script is a lightweight version of [my `compile-vim`
script](https://github.com/benknoble/Dotfiles/blob/master/links/bin/compile-vim)
that configures without Python, skips testing, and skips installing).

Note that we try compiling twice: I've seen some failures in configuring the
build that are solved by `make distclean`.

Then, the script runs our test case:

```shell
# negate: looking for bugfix. "old" needs to exit 0, "good" needs non-zero
VIMRUNTIME=runtime src/vim --clean -S <(cat <<EOF
try
	echo call({->'foo'}, [])
catch /./
	quit
endtry
cquit
EOF
)
```

I tested this against v9.1.1016, which I expected to be old (exit 0), and
against the start of my bisection (roughly v9.1.1435), which I expected to be
new (exit non-zero). It doesn't help to run a bisection that tests for the wrong
thing!

Finally, I started the bisection:
```shell
git bisect start
git bisect old v9.1.1016
git bisect new master
git bisect run ./bisect
```

Just a few minutes later, I had my answers. I saved the log for the curious:

```
git bisect start
# status : en attente d'un commit bon et d'un commit mauvais
# old: [1aefe1de0b20fe4966863e07efa14b6aa87323ee] patch 9.1.1016: Not possible to convert string2blob and blob2string
git bisect old 1aefe1de0b20fe4966863e07efa14b6aa87323ee
# status : en attente d'un mauvais commit, 1 commit bon connu
# new: [eb59129d2c06fd6627f537fce4fb8660cc8d0cda] runtime(typescript): remove Fixedgq() function from indent script
git bisect new eb59129d2c06fd6627f537fce4fb8660cc8d0cda
# new: [b42b9fc41f27f92aaf4f96cd4149f3160e9fe588] patch 9.1.1233: Coverity warns about NULL pointer when triggering WinResized
git bisect new b42b9fc41f27f92aaf4f96cd4149f3160e9fe588
# new: [066a5340e3d7ccc1fd9d1ee3ddf02cdc5ccf2813] CI: Install netbeans on windows to make sure to run test_netbeans.vim
git bisect new 066a5340e3d7ccc1fd9d1ee3ddf02cdc5ccf2813
# new: [4a530a632bb220b9aec827a12ab211a563c5583d] runtime(vim): Update base-syntax, match :debuggreedy count prefix
git bisect new 4a530a632bb220b9aec827a12ab211a563c5583d
# new: [9601b1435af427382682d923c57731f344e69dc4] translation(sr): Update Serbian messages translation
git bisect new 9601b1435af427382682d923c57731f344e69dc4
# new: [b77c5984877c9de816ea6db8865eb3df7bb14b51] patch 9.1.1032: link error when FEAT_SPELL not defined
git bisect new b77c5984877c9de816ea6db8865eb3df7bb14b51
# new: [166b1754a9b2046d678f59dedea7a3d693067047] patch 9.1.1025: wrong return type of blob2str()
git bisect new 166b1754a9b2046d678f59dedea7a3d693067047
# new: [037b028a2219d09bc97be04b300b2c0490c4268d] patch 9.1.1020: no way to get current selected item in a async context
git bisect new 037b028a2219d09bc97be04b300b2c0490c4268d
# new: [6472e583656aced8045fc852282708a684d77cfa] runtime(doc): fix base64 encode/decode examples
git bisect new 6472e583656aced8045fc852282708a684d77cfa
# new: [9904cbca4132f7376246a1a31305eb53e9530023] patch 9.1.1017: Vim9: Patch 9.1.1013 causes a few problems
git bisect new 9904cbca4132f7376246a1a31305eb53e9530023
# first new commit: [9904cbca4132f7376246a1a31305eb53e9530023] patch 9.1.1017: Vim9: Patch 9.1.1013 causes a few problems
```

## The fix

To my surprise, I was one coincidental patch away from the fix! [Version
9.1.1017](https://github.com/vim/vim/pull/16450) fixed a bug from
[9.1.1013](https://github.com/vim/vim/pull/16445) which was reported by
[#16453](https://github.com/vim/vim/issues/16453). The original patch was yet
another fix for [a different bug](https://github.com/vim/vim/issues/16430)
introduced by _another_ patch! Phew.

I later found that [the original bug](https://github.com/vim/vim/issues/16430)
contained some discussion on exactly my issue:

> Thanks a lot for addressing this!
>
> I have no issues with the fix, except that you may want to double check the
> workaround suggested by @zzzyxwvut in the comment above (using `call(Setup, [])`
> instead of `Setup()`). With Vim 9.1.1016, using `call()` raises an error:
>
>     E129: Function name required
>     E117: Unknown function: <lambda>26

and the [later bug](https://github.com/vim/vim/issues/16453) mentioned my repro
via `{-> 0}`.

While I don't grasp the full details of the fix, I can see tweaks to the C
function `f_call` which presumably implements Vim's `call()` function, and I can
see that it only "translates" the function name when given a string. Presumably
that means funcrefs (like those produced by lambdas) remain untranslated, which
makes sense if I assume that translation means "convert string to funcref."

Now I know!
