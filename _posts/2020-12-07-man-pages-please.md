---
title: 'Please *do* generate man-pages'
tags: [ rants, design, docs, productivity, open-source, shell, ]
category: [ Blog ]
---

The recent trend of not including man-pages with command-line "apps" ("tools" or
"programs" are better words!) irks me.

## Where is this coming from?

Many places. Specifically:

- personal observation of the trend that many command-line programs don't
support `man <program>`
- the [otherwise-full-of-solid-advice *Command Line
Guidelines*](https://clig.dev/), which says

> **Don’t bother with man pages**. We believe that if you’re following these
> guidelines for help and documentation, you won’t need man pages. Not enough
> people use man pages, and they don’t work on Windows. If your CLI framework
> and package manager make it easy to output man pages, go for it, but otherwise
> your time is best spent improving web docs and built-in help text.
>
> *Citation: [12 Factor CLI Apps](https://medium.com/@jdxcode/12-factor-cli-apps-dd3c227a0e46).*

(Emphasis in original)

- and the "original" [12 Factor CLI
Apps](https://medium.com/@jdxcode/12-factor-cli-apps-dd3c227a0e46) from Heroku:

> Unless you already know your users will want man pages, I wouldn’t bother also
> outputting them as they just aren’t used often enough anymore. Novice
> developers are unaware of them and they don’t work on Windows. Offline support
> isn’t necessary if you already have in-CLI help. Still, man page support is
> coming to oclif because in a framework I think it makes sense. It can be
> solved once for all oclif CLIs to reap the benefits.

## What's wrong with no man-pages?

Let's start with "what's *right* about no man-pages?". My answer: absolutely
nothing. It's laziness (and maybe a lack of good tooling). But if asciidoc and
other markup languages can convert to man-pages, it's time your program did too.

Now, what's actually wrong with not having them? Well, to answer that question,
I need to talk about how I use them.

I use man-pages for *reference*. Many of the best-written man-pages become
well-known, to the point where I can quickly navigate to the appropriate
section. Man-pages are nearly uniformly laid out for a reason.

I use man-pages for *convenience*. They are perfect when I just want to
double-check a flag without breaking my flow (`--help` isn't awful, but half the
time it takes me too many invocations to get the right help!). Opening a
web-browser is the epitome of breaking that flow: I actually left my work
context (the terminal, where the program is going to run), and I have to flip
between browser and terminal. Not hard on a wide screen, but on my laptop it's
not ideal. With a man-page, I know I can fire up a tmux pane or vim-split (thank
you, `:Man`) to browse without disturbing my current context. Man-pages are
nearly uniformly laid out for a reason.

Just to emphasize this, `:Man` ships with vim. In any vim, I can run that
command (possibly prefaced by `:runtime ftplugin/man.vim`) and get a man-page.
Conversely, it is harder to get the output of `--help` and friends where I want
it. Some options:

{% highlight vim %}
" 1. put it directly in the buffer
:read !program --help
" clutters the buffer… so,
" 2. new buffer
:new | read !program --help
" too much typing…
" 3. a plugin, such as Clam
:Clam program --help
" not portable, and still extra typing (though only by 6 characters)
{% endhighlight %}

> Aside: this is a pain-point for me when I start working with certain
> languages. With C, `K` and `keywordprg=:Man` is usually good enough (and tags
> make up the difference). With Rust & Python, it's been a hack-filled journey
> to get decent in-editor documentation support (and for Rust I almost always
> have to open a web-browser, even if it's with a hot-key). For my workhorse
> SML, the only docs are web-browsed or local HTML pages. For lots of other
> languages, there's just not much. Is it too much to ask programming-language
> designers to support local, text-based documentation in a program-consumable
> format? It doesn't have to be a man-page, but *something*.

I use man-pages for *search-ability* and general text-manipulation. I have
configured `MANPAGER` to use vim, so I have a powerful set of tools to deal
with programs and their documentation. I even have maps for `-` and `_` to start
searching for short (`-x`) and long (`--x…`) flags, which makes for a quick
browse (when formatted appropriately). I can't do that with `--help` as easily
(`grep`ping doesn't usually cut it), and even `less` as a pager has pretty poor
search ability. Say it with me: Man-pages are nearly uniformly laid out for a
reason.

Personally, I use man-pages to *learn*. When I'm not sure how something works, I
can usually figure out from a good `man thing`. This isn't really a selling
point, but it is a part of many workflows. "Man" stands for "manual," after all:
or do people not read those anymore?

All this to say that what's wrong with no man-pages is a lack of these things,
particularly convenience and non-workflow-breaking-documentation.

## No man-page is better than a bad one

I'm looking at you [`gh`](https://cli.github.com). Your documentation, frankly,
is atrocious. Only a sentence at worst that doesn't actually tell me what you
do! And the flag documentation is frankly so ambiguous that I've written
commands with mutually exclusive flags set because it wasn't at all clear that
only one was allowed. (`gh repo fork --clone false --remote true` seems
reasonable, no?).

So, don't provide a man-page if it's poor. But maybe find a way to write some
good documentation that could be converted to a man-page (or vice-versa)?

## If not a man-page…

Well, something like vim's `:help` is *fantastic*. It's not for every program,
but any seriously interactive (especially full-screen) program should consider
something of the sort. It helps that the system is extendable and plain text,
too.

## A few considered counter-arguments

- "Doesn't work on Windows": valid point. But what does? (Joking aside, surely
there's *something* that works as a documentation format for the Windows
terminal besides HTML?)

- "Novices aren't aware": so educate them. Part of CLIG's shtick was to educate
users when they make a mistake with your command. It's as easy as keeping
`--help` brief with a pointer to "see `man program` for more details".

    Following up on that, I don't consider `--help` to the end-all-be-all of
    documentation, as you've probably noticed. I only type `--help` when I'm
    sure it will be quick and useful: generally, a usage summary and a "Top 5"
    common options/invocations. Sometimes it's to re-assure myself that the
    command does what I think it does, like when I use one of the more obscure
    git commands. When I want the whole book, I go to the man-page. Too-long
    `--help` is "saying too much" in the words of CLIG.

- "Offline support isn't necessary if you already have in-CLI help": false. (Or
at least, I disagree.) Solution proposed: generate man-pages from in-CLI help or
vice-versa. I favor the latter, actually, but I'm probably in the minority on
that. I find that it's nicer to write documentation in a textual format rather
than in strings in code, especially in some languages. (Newlines? Continuations?
Leading spaces? Ugh. Format it for me---I don't want to have to care.)

- "otherwise your time is best spent improving web docs and built-in help text":
see above solution. They could all be one and the same (or at least tied
together: sure, a tutorial might not be a good candidate for a man-page, at
least for smaller programs. But it could link to an HTML version of the page
that lives in my terminal.).
