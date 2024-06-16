---
title: Day match [0-9]—Regex
tags: [ til, infra, intern, tcl, regex, posix ]
category: Blog
---

This is __not__ a regex tutorial. Those are in the manpages.

# Today I Learned

1. I am more productive on Ubuntu than CentOS
2. A little bit of tcl
3. A lot (more) regex

## Ubuntu 18.04

I got my official machine running last night, but actually worked on it for the
first time today. I'm still using the CentOS laptop because that's where my
current code is, and I haven't configured the VPN yet. But for the things I was
doing (Slack, email, web, even getting my [Dotfiles][] setup), I felt much
better.

Ubuntu terminal even supports truecolor and italics out of the box!

## Tickle

Yes, it's really pronounced that way. Apparently the language is revered for
both it's simplicity and it's use in networking situations. I wouldn't know; we
use it for some test suits (part of gash, the whole setup was never explained to
me). And today I had to use a little to fix a broken build.

It was broken because of...

## Regex ! :tada:

[You know what they say...][regex]

So, here's the deal. Like I said, I'm not going to give a tutorial on regex. The
manpages are actually pretty good at it. But I am going to point you to them,
just so you can enjoy the ~~hell~~ many flavors of regex. (None of them taste
good.)

POSIX gives us:

1. Basic (obsolete) RE
2. Extended (modern) RE
3. Enhanced (B\|E)RE (I had to escape that bar in markdown, yeesh)

You can read about them at `man re_format` and `man regex`.

Most UNIX-like utilities (`sed`, `grep`) use BREs, with a flag (usually `-E`)
for extended. Whether or not it is enhanced can be gleaned from the manpages
(does it, for example, support black magic). Basically, `man` and `info` the
tool.

After that, we basically have the following

1. Perl, on which most other regex is based (`man perlrequick`)
2. Vim, with it's own quirks (`:help pattern`)
3. Python (`help(re)`)
4. ...and every other language's unique flavor

Don't get me started on escape-character hell--no one should have to read
`"\\"\\\\"` and try to figure out what it's doing. Heck, certain formats even
have special rules and tables for *when* characters have special meaning or need
escaped (vim's `(very)?magic` is famous for this).

Does it support back references? Capture groups? What the hell is a negative
look-behind? Why did vim decide to give us `\zs` and `\ze` (they're brilliantly
useful, by the way) ? And what about [non-greedy modifiers ??][??]

Can I use my favorite feature of all, shortcut character classes? This one
really gets me steamed up--shortcuts like `\w` for word-like characters and `\d`
for digits are really helpful. It's *short*er than the equivalent `[:digit:]`,
which often has to become `[[:digit:]]` for true RE use.

What I recently discovered, though, is that `sed` natively supports *certain*
shortcuts. And digit isn't one of them.

So, the regex in the post of this title will match the number of days I've
worked up 'til now, but `\d` won't. At least not in `sed`. And tomorrow, it gets
even better.

[Dotfiles]: {{ site.data.people.benknoble.github }}/Dotfiles
[regex]: https://www.explainxkcd.com/wiki/index.php/1171:_Perl_Problems
[??]: https://www.ultraedit.com/support/tutorials-power-tips/ultraedit/non-greedy-perl-regex.html
