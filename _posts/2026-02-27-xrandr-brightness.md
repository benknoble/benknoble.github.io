---
title: xrandr brightness glitch
tags: [ linux ]
category: [ Blog ]
---

I've had this glitch twice now, where I wake up my external monitor and the
screen is washed out with brightness. I can see enough to try to fix it, but
it's not the hardware brightness settings. The software brightness settings are
out of wack.

**Update 2026-08-23:** This happened again today. Below did not fix my problem;
at brightness 1, things were washed out. Setting down to 0.5 helped me read, but
wasn't displaying as I am used to. Unplugging the display, power cycling,
re-plugging it, then re-setting brightness to 1 seems to have fixed it. I
checked a diff of `xrandr --verbose` before and after and saw no significant
differences (just timestamps and the manually adjusted brightness value). Very
strange.

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
