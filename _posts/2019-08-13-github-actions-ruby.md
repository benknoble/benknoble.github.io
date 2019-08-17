---
title: 'Ruby, where are you (in GitHub workflows)?'
tags: [ git, github, github-workflow, ruby, ci ]
category: [ Blog ]
---

A treasure hunt for ruby in the beta of GitHub actions and workflows leaves me
scratching my head...

GitHub recently opened up the workflows/actions to a public beta, and I'm in it.

> Aside: A *workflow* is the `.github/workflows/*.yml` file that contains the
> actual workflow, while an *action* is more nebulous (Docker stuff, repos,
> etc.). This naming overlap makes it difficult to talk about, so I'll stick to
> workflow.

I went through all my repos and decided to setup CI workflows for each one. I
may add other things later, like stale-issue-organizers or deployment workflows,
but I wanted to start simple.

And then I did my [Dotfiles][].

## Results

For the interested, it ended up being a great way to check the compatibility of
my dotfiles across Mac and Ubuntu. I ended up finding and fixing several bugs,
and I'm glad I have this now.

However, there was one big hiccup, and I've documented it for you in all it's
glory: [ruby, where are
you?][ruby].

### Needing Ruby

I need ruby because I need to run some downloaded ruby code to install brew as
part of the `make install` process of my dotfiles:

```
/usr/bin/ruby -e "$( curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install )"
/bin/sh: 1: /usr/bin/ruby: not found
Makefile:56: recipe for target 'brew_install' failed
make: *** [brew_install] Error 127
```

But as you can see, ruby is nowhere to be found.

> Aside: There are other issues with that line of code; namely, we need
> LinuxBrew on Ubuntu instead of Homebrew, and not all rubies are
> `/usr/bin/ruby`. These have since been corrected.

### It exists...

I was *baffled*. [Ruby is provided in all the
environments](https://help.github.com/en/articles/software-in-virtual-environments-for-github-actions)!

### Treasure Hunt

Flummoxed, I spent hours [crafting commits to find a ruby executable][ruby]. I
was largely unsuccessful, and eventually filed a GitHub support request.

> Aside: I've done one of those before, but it seemed like they had a whole
> forum system, and now it's just a little email. I can't find any kind of
> forum, and I have no response from them at this time (beyond confirmation of
> receipt). If anyone knows what happened to the forums or where they are,
> please comment below.

Here's some logs for you: [a
gist](https://gist.github.com/benknoble/126bce506f2326b17cdef0402bf78fa0).

Then, I discovered [this little
gem](https://github.com/benknoble/Dotfiles/commit/d49f2ff86326628aa8fc52f0ae1b7eccbfdbbc5a).
It's [still not quite
perfect](https://github.com/benknoble/Dotfiles/commit/bcbf971e679b96f7cfa71f635b31771b87aaad31),
but somehow in reading all of the documentation it was never mentioned that
common environments (node, python, ruby) need setup actions.

So, when you need ruby for a GitHub workflow:


```yaml
- uses: actions/setup-ruby@v1
  with:
    ruby-version: 2.6.x
```

[Dotfiles]: {{ site.data.people.benknoble.dotfiles }}
[ruby]: https://github.com/benknoble/Dotfiles/commits/ruby-where-are-you
