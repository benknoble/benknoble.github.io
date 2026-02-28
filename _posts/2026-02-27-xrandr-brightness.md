---
title: xrandr brightness glitch
tags: [ linux ]
category: [ Blog ]
---

I've had this glitch twice now, where I wake up my external monitor and the
screen is washed out with brightness. I can see enough to try to fix it, but
it's not the hardware brightness settings. The software brightness settings are
out of wack.

I think both times I've ended up fixing this by rebooting, but I recently
learned that I can use `xrandr` to control the software brightness like

```
xrandr --output DisplayPort-3 --brightness 1
```

You'll have to adjust for your output device, of course. The `brightness` value
appears to be a scale factor, so fractions dim the output and values greater
than 1 lead to the wash out effect.

I'm not sure _what_ toggled the `xrandr` setting, but at least next time I'll
have an idea of how to fix it.
