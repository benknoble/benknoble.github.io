---
title: About
permalink: /about/
---
### The Site

[Junk Drawer][site] is hosted by [GitHub][github] Pages and powered by the
[Jekyll][jekyll] engine.

### Junk Drawer

So, what is the "Junk Drawer"? Good question. In my everyday life, no matter
where I'm living or working, there's always a drawer or desk space or shelf or
shoe box where I throw flyers, books, notes, scribbles, and thoughts. It's a
catchall, and often times it gets quite cluttered.

This blog is dedicated to being a virtual representation of my junk drawers,
holding musings and notes from my life. Primarily, I will try to write about
programming, but I will frequently digress to other topics, such as math,
language (reading, writing, or programming), music, or D&D.

To see my virtual Junk Drawer on GitHub, visit [benknoble/JunkDrawer][junk].

### Me

I'm D. Ben Knoble, an graduate Computer Science student at UNC Chapel Hill. I
completed my undergraduate degree in CS and French, with a minor in Mathematics.
I am now pursuing a Master's in CS.

I rely on a healthy mix of self-taught experimentation and formal class training
for anything I do, including programming. Being self-taught keeps me curious. My
biggest personal interests in the computer science sphere are programming
languages and programming tools. Outside of that, I'm an avid biker,
clarinetist, martial artist, reader, and gamer.

I'm keeping track of my "developer level" via a [set of challenges that span a
broad array of programming, development, learning, and teaching
categories](https://benknoble.github.io/level-up/).

For some of the projects I'm working on, check out
[benknoble@GitHub][benknoble], or try my [showcase][showcase]. I'm also on
the Stack Exchange network (primarly [vim][vim], though I still use
[StackOverflow][stack_overflow] as well as a few others).

{% include SO_flair.html %}
{% include github_flair.html %}

Please [contact me][contact] with questions, corrections, or to chat.

### Technical

- Favorite __editor__: `vim`.

Editing should be done at the speed of thought, not the speed of click-and-drag
or the speed of which-function-key-is-it

- Favorite __IDE__: `tmux`.

No, it's not an IDE like Eclipse. It *is* a great way to manage projects and
terminals. (Note: I don't even use iTerm!  Terminal.app is good enough with
tmux, even if it doesn't support truecolor yet.)

- Favorite __shell__: `bash`.

It's the default; it's what I learned; it's just simple enough to be a really
great shell (the core really is small). It does what I need and doesn't get in
my way. It's easier to configure than zsh, and forces me not to rely on *too*
many non-portable-isms. I do wish sh would get proper (associative) arrays.

I have [switched to zsh]({% link _posts/2020-05-21-switch-zsh.md %}) for
interactive use, but bash and sh are still my automation go-tos.

- Favorite __languages__: a mix of `shell`, `make`, `vimscript`, and the
functional stuff.

I've written enough SML to really enjoy it (see my entries for the 2019 Advent
of Code, for example). Scala and Clojure are fun, but the JVM dependence makes
it too heavy for me most of the time. I appreciate the true smallness of C, and
have learned a lot from it. Haskell and Rust are next on my list. Then some new
paradigms: maybe true logic programming or something. After that,
something older and something esoteric.

(Languages I'm tired of? `python` and `javascript` make the top of the list. The
former is everywhere, but it's functional-language side isn't on par with things
like SML or Clojure. The latter is, well, broken, though Deno seems to be making
progress.)

- Favorite __OS__: `macOS`.

I've been using a macbook since 2012 and it's here to stay. I'm not convinced on
the new touchbar thing yet though.

- Favorite __version control__: definitely `git`.

I think some people prefer the mercurial (hg) interface, but I'm not sold. Git
has outgrown its historical reputation for a complex interface, and is the de
facto standard.

- Favorite **keyboard**: my Ergodox EZ. Here's my
[layout](https://configure.zsa.io/ergodox-ez/layouts/BNalB/latest/0).

<!-- Links -->
[github]: https://github.com/
[jekyll]: http://jekyllrb.com
[benknoble]: {{ site.data.people.benknoble.github }}
[stack_overflow]: {{ site.data.people.benknoble.stack_overflow }}
[junk]: {{ site.data.people.benknoble.junk_drawer }}
[vim]: {{ site.data.people.benknoble.vi_se }}
[showcase]: {{ site.data.people.benknoble.portfolio }}
[site]: https://github.com/{{ site.repository }}
[contact]: /contact/
