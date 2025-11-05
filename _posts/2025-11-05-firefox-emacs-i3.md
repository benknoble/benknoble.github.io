---
title: 'Firefox with "normal" editing shortcuts in i3'
tags: [linux, gentoo]
category: Blog
---

My "desktop environment" is just i3 at this point, so there's no GNOME or other
Gtk environment to meet the [shortcuts enabled in GNOME
requirement](https://support.mozilla.org/en-US/kb/keyboard-shortcuts-perform-firefox-tasks-quickly#w_developer-shortcuts).

Fortunately, there's a way around that. After cobbling together [a post from
2004](http://www.linuxfocus.org/English/December2004/article358.shtml) (which no
longer works but points in the right direction) with [a much more recent
post](https://blog.karssen.org/2024/06/05/using-emacs-key-bindings-in-gnome-firefox-and-other-applications/),
the following appears to work:

```
gsettings set org.gnome.desktop.interface gtk-key-theme Emacs
mkdir -p ~/.config/gtk-3.0
cat <<EOF >settings.ini
[Settings]
gtk-key-theme-name = Emacs
EOF
```

and restart Firefox. Note I'm using the Gentoo desktop profile, so `gsettings`
and the gtk config directory already existed despite not running GNOME.

The only caveat I have so far is that I now have to exit focus from text inputs,
including the address bar, before I can use Firefox shortcuts like C-h
(history).

The latter article also mentions
[`ui.key.accelKey`](https://kb.mozillazine.org/About:config_entries#UI.), which
pointed me to `generalAccessKey`, too. I might experiment with using other keys
there, once I know what they control.

**Update later that day:** It seems `generalAccessKey=224` lets me use Command
(Meta), and I'm not sure changing `accelKey` had any real affect. The one
downside here is that M-q quits without warning despite those settings not
changing. Oh well.

PS I know, there's probably a way to get Vim + Firefox to work these days. I'll
explore that later. For now, I'm used to browsers, Slack, and others at least
letting me edit from a sensible part of my keyboard (C-n, C-a, C-k, etc.) when
I'm not in Vim.
