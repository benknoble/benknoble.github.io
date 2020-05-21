---
title: 'Why I finally switched to zsh'
tags: [ productivity, prog-langs, shell, zsh ]
category: [ Blog ]
---

Some people were astonished I still used bash (though I was on version 5+).

## Ok, I finally switched, but

I spent the last week getting my toes wet, reading the [FAQ][], [User's
Guide][], and [Manual][] cover-to-cover, and porting my bash config over to zsh.
It is at last done, and I have to say I'm happy enough with zsh to have `chsh`ed
to it.

But why?

Ultimately, it took me this long to make the switch because

- I like bash
- I had a *lot* of bash configuration
- `zsh` is *huge*---it's a daunting task to even set up a simple config
- I consider myself something of an expert in bash

This last point is really the stickler: I like to be an expert in the systems I
use (no Oh-my-zsh for me). I became an expert in bash precisely because the core
is so small; I am a long way from mastering zshell and its hieroglyphs.

But, ultimately, I had to recognize that it is likely to bring me performance
gains in the many years to come. I'll have

- a better command-line editor
- more powerful completions
- more powerful globs and qualifiers
- better startup-file rules
- mechanisms for autoloading (much like in vim)
- and more...

To be clear, zsh is not here to replace bash. Bash is still a mainstay of my
scripting and automation world; I'm not giving up that expertise, and it ranks
2nd in terms of portability (`/bin/sh` taking first place).

But zsh might just be this programmer's paradise… for proof, consider how some
of my zsh configuration is simpler than its bash counterpart (and the more
complex pieces tend to be the result of more complex, but more powerful and
ultimately productive, systems).

[FAQ]: http://zsh.sourceforge.net/FAQ/zshfaq.html
[User's Guide]: http://zsh.sourceforge.net/Guide/zshguide.html
[Manual]: http://zsh.sourceforge.net/Doc/zsh_us.pdf
