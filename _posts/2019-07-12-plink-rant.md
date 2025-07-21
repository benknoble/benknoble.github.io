---
title: 'Something is rotten in the state of Dotfiles'
tags: [ dotfiles, make, perl, shell, DSL, rants, design, posix ]
category: [ Blog ]
---

After a [recent adventure][make_merge] rewriting my entire [Dotfiles][] system
to use [POSIX make][posix_make], I wanted something better.

First, let's survey the state of Dotfiles the world over.

## The Good

Most Dotfiles collections are shared on the internet via [GitHub][gh_dot], and
reading them is a fun pastime. They're a great way to get insight into others'
workflow, and learn new tricks.

## The Bad

Most Dotfiles, however, use radically different setup schemes and directory
structures. Some have hand-crafted shell scripts (see my repo's early
history...); some prefer self-written tools (thoughtbot uses an in-house ruby
tool called `rcm` IIRC); some use GNU Stow; some use make (myself included);
some just list instructions in the README.

As a programmer, this variety of tools is exciting when it means people are
thinking about how to solve the problem. Unfortunately, with few notable and
widespread exceptions, these tools are all hand-crafted. While I will argue that
Dotfiles are extremely personal and deserve to be hand-crafted, their management
may not deserve the same.

The difficulty with the variety is that is hard for me to benefit from someone
else's setup script/tool/makefile/etc. It's simply too personal, and often too
hand-written. At least with my original scripts I eventually converted to an
associative array, sticking with the convention that keys would be entries under
`links` and values would be the eventual symlinks under `~`.

## The Ugly

This complaint is mostly because I took pains to get to POSIX make (and *only*
POSIX make), throwing out all the shell scripts I'd accumulated over the years,
the backups that get made of old Dotfiles, and the incessant prompting and
messaging. (I finally settled for a trust myself mentality there.)

But let's take a look at some code from the current Makefile (the most recent
version is always on [GitHub][Dotfiles]):

```make
LINKS = links
# all the eventual symlinks in ~
SYMLINKS = \
$(HOME)/.ackrc \
$(HOME)/.bash \
$(HOME)/.bash_profile \
$(HOME)/.bashrc \
$(HOME)/.bin \
$(HOME)/.ctags.d \
$(HOME)/.git_template \
$(HOME)/.gitconfig \
$(HOME)/.gitignore_global \
$(HOME)/.gitshrc \
$(HOME)/.inputrc \
$(HOME)/.jupyter \
$(HOME)/.pythonrc \
$(HOME)/.tmplr \
$(HOME)/.tmux.conf \
$(HOME)/.vim \


# note the extra trailing newline,
# just so I don't have to see diffs with \ in them

# dependencies
$(HOME)/.ackrc: $(LINKS)/ackrc
$(HOME)/.bash: $(LINKS)/bash
$(HOME)/.bash_profile: $(LINKS)/bash_profile
$(HOME)/.bashrc: $(LINKS)/bashrc
$(HOME)/.bin: $(LINKS)/bin
$(HOME)/.ctags.d: $(LINKS)/ctags.d
$(HOME)/.git_template: $(LINKS)/git_template
$(HOME)/.gitconfig: $(LINKS)/gitconfig
$(HOME)/.gitignore_global: $(LINKS)/gitignore_global
$(HOME)/.gitshrc: $(LINKS)/gitshrc
$(HOME)/.inputrc: $(LINKS)/inputrc
$(HOME)/.jupyter: $(LINKS)/jupyter
$(HOME)/.pythonrc: $(LINKS)/pythonrc
$(HOME)/.tmplr: $(LINKS)/tmplr
$(HOME)/.tmux.conf: $(LINKS)/tmux.conf
$(HOME)/.vim: $(LINKS)/vim
```

Yes, I copy-pasta'd that verbatim for your benefit. Look at the overwhelming
redundancy! It makes the programmer cringe: why bother writing code to automate
these tasks if you can't write *good* code? This is begging me to update one
list and not the other; adding only to `SYMLINKS` will cause `make symlinks` to
run all the time trying to build a file that won't exist, while adding only to
the dependencies will cause `make symlinks` to ignore a symlink I want to
create! Ugh. There has to be a better solution

## Plink

My preferred solution would be a DSL that could generate exactly (or
near-exactly) the current Makefile I'm using. This DSL would let me specify the
necessary and sufficient information (how files link together), and figure out
the rest. It would output POSIX make for any generated code.

Better, it would give me syntactic sugar for common make idioms (like phony
targets to run commands), and pass on *everything* that isn't part of its syntax
exactly as-is to make (this includes `#` comments!).

Finally, if the program generates a Makefile, it might as well have all targets
it creates (and possibly all targets, though this requires parsing make
constructs) depend on the original DSL file! Then, with careful writing, `make
symlink` will first rebuild the Makefile if necessary, *then* generate the
missing symlinks.

Enter, `plink`. It's in rough design stage, but it should look something like
this when I'm done (this would be called something like `links.plink`):

```sh
#! /usr/bin/env ./plink_submodule/plink

# literal make syntax
MY_VAR = value

target: $(MY_VAR)

# describes that the file ~/link comes from the file ./dotfile
link <= dotfile

# gives me a target with a recipe consisting of exactly the text of command
phony_name ! command

# gives me a target with a recipe consisting of exactly the text of commands...
phony_name2 !!
commands...
!!
```

It shall be called plink because I will be writing in Perl and it will be used
to manage my symlink-based Dotfiles. It will be so easy to use that all you need
is to make plink a submodule, create your executable plink file (if you don't
have `env`, just make the interpreter the relative path to `plink`), and run it
to get a Makefile with the semantics I've described above.

The `env` magic is to work around the fact that interpreters on shebangs cannot
be nested (since `plink` starts with `#! /usr/bin/env perl`, this is an issue).
`env` doesn't care. It runs plink just fine.

I'm still working out exactly the design of plink (I need to decide how ordering
of the plink file will work, and if there are semantics for what becomes the
default make target—and I really need to decide whether or not to generate
unspecified code: see the lines for `SUFFIXES` and `SHELL` in the original). But
it should be done soon—that's the advantage of Perl's text-processing power.

P.S. I know I'm solving a tool problem with another hand-crafted tool, but the
DSL is just too powerful to resist, and it could easily be universal because it
emits POSIX make. Users can customize as they want because of the way it passes
everything else literally to make.

P.P.S. A vim plugin for plink will be stupid simple: I just have to include the
make syntax, then add some rules for plink's syntax, and we're off to the races.

[make_merge]: https://github.com/benknoble/Dotfiles/commit/2662480d79a072cc55c58e444cc7c622085a621f
[posix_make]: http://pubs.opengroup.org/onlinepubs/009695399/utilities/make.html
[Dotfiles]: {{ site.data.people.benknoble.dotfiles }}
[gh_dot]: http://dotfiles.github.io
