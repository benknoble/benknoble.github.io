---
title: NetworkManager resetting hostname to localhost.localdomain
tags: [ linux, network ]
category: [ Blog ]
---

I explain (as best I can) how I figured out what screwed up my machine's
hostname the day before a vacation.

July 8th, I'm getting ready to be out of town, and doing a few updates to my
daily driver (beefy PC running Gentoo). There's a kernel update available, and I
want to reboot and make sure everything comes up so it will be accessible via
TailScale while I'm out of town.

Imagine my surprise when the reboot shows the hostname as `localhost`!

Well, that's odd, I think---must be the new kernel. So I reboot and use GRUB to
load the previous kernel, which I of course still have around. No change, big
scary. And of course, after launching X and trying to reset the hostname
manually, things break even worse. Uh oh, my desktop is broken too? I can't
start new programs? What is going on?

This feels like a _really_ bad upgrade.

---

I spent a few hours poking around, assuming that my desktop issues and my
hostname issues were separate. I even figured maybe TailScale was futzing it up
somehow, so I tried booting with that disabled---no luck. I had dinner plans
with my family, though, so I had to give up and leave (machine powered down).

While there, I realized my best shot was to revert all the updates I had done
and slowly try to narrow down which update broke things. I could of course
restore from the prior night's backup, but… I'd spent the morning setting up
Wine to run an old childhood favorite (I Spy Spooky Mansion), and I didn't want
to have to redo that work. So, I really wanted to try downgrading first.

When I got home, I set out to do that, eyeballing the `qlop` output:

```shell
$ qlop -d 2026-07-07 -d 2026-07-09 -E
N    app-emulation/wine-gecko-2.47.4
N    app-emulation/wine-mono-10.4.1
N    app-eselect/eselect-wine-2.0.2-r2
N    sys-libs/libunwind-1.8.3
N    app-emulation/wine-desktop-common-20150204-r2
N    dev-util/mingw64-toolchain-14.0.0
N    app-emulation/wine-vanilla-11.0
  U  dev-libs/vala-common-0.56.19 [0.56.18]
  U  dev-libs/libunistring-1.4.2 [1.3]
  U  sys-apps/sandbox-2.49 [2.46]
  U  dev-libs/gobject-introspection-common-1.86.0 [1.84.0]
  U  app-containers/containerd-2.2.5-r1 [2.2.2-r1]
  U  app-admin/eselect-1.4.32 [1.4.31]
N    media-libs/libid3tag-0.16.4
  U  kde-frameworks/extra-cmake-modules-6.27.0 [6.25.0]
  U  app-eselect/eselect-lua-4-r3 [4-r2]
N    dev-libs/snowball-stemmer-3.1.1
N    dev-cpp/simdutf-9.0.0
  U  dev-python/snakeoil-0.11.1 [0.11.0]
  U  sys-apps/portage-3.0.81.1 [3.0.79-r1]
N    dev-util/glib-utils-2.88.2
N    sys-apps/pkgcore-0.12.35
N    sys-kernel/gentoo-kernel-6.18.37_p1
 R   net-libs/nodejs-24.14.0
N    virtual/dist-kernel-6.18.37_p1
  U  dev-util/pkgcheck-0.10.40-r1 [0.10.39-r1]
  U  dev-libs/glib-2.88.2 [2.84.4-r5]
  U  dev-util/gdbus-codegen-2.88.2 [2.84.4]
  U  app-text/enchant-2.8.16 [2.8.12]
  U  dev-libs/gobject-introspection-1.86.0 [1.84.0-r2]
  U  sys-apps/hwloc-2.12.2 [2.11.2-r1]
  U  net-print/cups-2.4.19 [2.4.16]
  U  dev-lang/vala-0.56.19 [0.56.18]
  U  dev-python/pygobject-3.56.3 [3.50.1]
  U  x11-libs/pango-1.57.1 [1.57.0]
  U  gnome-base/librsvg-2.62.2-r1 [2.60.0]
 R   media-libs/imlib2-1.12.6
  U  x11-libs/gtk+-3.24.52 [3.24.51]
N    gui-libs/qt-color-widgets-3.0.0
N    dev-libs/appstream-1.0.6
N    kde-frameworks/kguiaddons-6.27.0
N    kde-frameworks/threadweaver-6.27.0
N    kde-frameworks/ksecretd-services-6.27.0
N    kde-frameworks/ki18n-6.27.0
N    kde-frameworks/kcoreaddons-6.27.0
N    kde-frameworks/kconfig-6.27.0
N    kde-frameworks/karchive-6.27.0
N    kde-frameworks/kcodecs-6.27.0
N    kde-frameworks/kitemviews-6.27.0
N    kde-frameworks/kdbusaddons-6.27.0
N    kde-frameworks/breeze-icons-6.27.0
N    kde-frameworks/kwindowsystem-6.27.0
N    kde-frameworks/kglobalaccel-6.27.0
N    kde-frameworks/kwidgetsaddons-6.27.0
N    kde-frameworks/sonnet-6.27.0
N    kde-frameworks/solid-6.27.0
N    kde-frameworks/kirigami-6.27.0
  U  net-misc/networkmanager-1.56.0 [1.52.1]
  U  media-video/pipewire-1.6.7 [1.6.4]
  U  net-libs/webkit-gtk-2.52.3-r411 [2.50.5-r410]
N    kde-frameworks/kcrash-6.27.0
N    kde-apps/libkexiv2-26.04.3
N    kde-frameworks/kcolorscheme-6.27.0
N    kde-frameworks/kcompletion-6.27.0
N    media-gfx/flameshot-13.3.0
N    kde-frameworks/kpty-6.27.0
N    kde-frameworks/kdoctools-6.27.0
  U  kde-frameworks/kimageformats-6.27.0 [6.25.0]
  U  media-video/wireplumber-0.5.15 [0.5.14]
  U  kde-frameworks/knotifications-6.27.0 [6.25.0]
N    kde-frameworks/kservice-6.27.0
N    kde-frameworks/ktextwidgets-6.27.0
N    kde-frameworks/kjobwidgets-6.27.0
N    kde-frameworks/kconfigwidgets-6.27.0
  U  kde-frameworks/kiconthemes-6.27.0 [6.25.0]
N    www-client/firefox-bin-152.0.5
N    kde-frameworks/kded-6.27.0
N    kde-frameworks/kbookmarks-6.27.0
N    kde-frameworks/kxmlgui-6.27.0
  U  kde-frameworks/kwallet-6.27.0 [6.25.0]
  U  kde-frameworks/kwallet-runtime-6.27.0 [6.25.0]
  U  kde-frameworks/kio-6.27.0 [6.25.0]
  U  kde-frameworks/kparts-6.27.0 [6.25.0]
  U  kde-frameworks/kcmutils-6.27.0 [6.25.0]
  U  kde-apps/okular-26.04.3 [26.04.1]
```

Something interesting stood out: NetworkManager.

The [NEWS file for
NetworkManager](https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/main/NEWS?ref_type=heads)
didn't hint at significant changes in hostname settings, though. A little
internet searching brought me to [a blog post about v1.40 and a similar
issue](https://networkmanager.dev/blog/addressing-hostname-assignment-in-networkmanager-1-40/),
which definitely felt like the right track! Only, I've been running 1.52.1 for
the (admittedly short: not quite 12 months yet) lifetime of the machine, and the
upgrade was to 1.56.0!

Anyway, that article also pointed me towards GLib, which I noticed had a few
updates as well:

```
  U  dev-libs/glib-2.88.2 [2.84.4-r5]
  U  dev-util/gdbus-codegen-2.88.2 [2.84.4]
```

(Once again nothing in the [NEWS
file](https://gitlab.gnome.org/GNOME/glib/-/blob/main/NEWS?ref_type=heads) stood
out.)

So, I next tried downgrading only those packages (more `qlop` output):

```
  UD net-misc/networkmanager-1.52.1 [1.56.0]
  UD dev-libs/glib-2.84.4-r5 [2.88.2]
  UD dev-util/gdbus-codegen-2.84.4 [2.88.2]
```

Absolutely no change (with either kernel)! Agh!

At some point in this process, I decided to narrow down the desktop issue, and I
discovered that programs wouldn't start on the desktop if the hostname didn't
match what it was when the X server started. I can't 100% explain this (is it
because X is network aware? Because of DBus addresses?), but it did give me hope
that solving this hostname would fix everything else.

Now that I knew NetworkManager was a likely culprit, too, I went back to logs
with a more useful query than `localhost` or `hostname`. And I noticed something
a bit suspicious:

```
/var/log/syslog:Jul  8 20:59:51 merguez NetworkManager[1966]: <info>  [1783558791.7113] hostname: static hostname changed from (none) to "localhost"
```

First: why is it being changed? Second, why does it say "(none)" as the old
value?

Even more worrying, this has been happening for a long while:

```shell
$ zgrep 'to "localhost' /var/log/syslog*
/var/log/syslog:Jul  8 20:59:51 merguez NetworkManager[1966]: <info>  [1783558791.7113] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog:Jul  8 21:09:06 merguez NetworkManager[15809]: <info>  [1783559346.0807] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog:Jul  8 21:32:41 merguez NetworkManager[15809]: <info>  [1783560761.1627] hostname: static hostname changed from "merguez" to "localhost"
/var/log/syslog:Jul  8 21:35:40 merguez NetworkManager[46052]: <info>  [1783560940.6739] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog:Jul  8 21:38:50 merguez NetworkManager[60328]: <info>  [1783561130.4501] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog:Jul  8 21:40:15 merguez NetworkManager[2049]: <info>  [1783561215.0657] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.0:May 10 10:58:15 merguez NetworkManager[1980]: <info>  [1778425095.8529] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.0:May 15 15:58:44 merguez NetworkManager[2062]: <info>  [1778875124.9800] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.0:Jun  4 17:10:13 merguez NetworkManager[2029]: <info>  [1780607413.9324] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.0:Jun  8 14:22:36 merguez NetworkManager[1992]: <info>  [1780942956.6790] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.0:Jun  8 15:31:16 merguez NetworkManager[1982]: <info>  [1780947076.9328] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.0:Jun 19 10:22:04 merguez NetworkManager[2247]: <info>  [1781878924.8232] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.0:Jun 21 13:39:01 merguez NetworkManager[2027]: <info>  [1782063542.0005] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.0:Jun 27 20:42:37 merguez NetworkManager[2228]: <info>  [1782607357.8853] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.0:Jul  8 18:29:06 merguez NetworkManager[2051]: <info>  [1783549746.1208] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.0:Jul  8 18:33:03 merguez NetworkManager[7510]: <info>  [1783549983.6724] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.0:Jul  8 18:34:00 merguez NetworkManager[1960]: <info>  [1783550040.8156] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.0:Jul  8 18:44:49 merguez NetworkManager[2036]: <info>  [1783550689.9128] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.0:Jul  8 18:47:33 merguez NetworkManager[1974]: <info>  [1783550853.7683] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.1.gz:Mar 26 12:55:06 merguez NetworkManager[2078]: <info>  [1774544106.9472] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.1.gz:Apr 27 17:25:16 merguez NetworkManager[1998]: <info>  [1777325116.8897] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.1.gz:May  4 16:43:30 merguez NetworkManager[2002]: <info>  [1777927410.6758] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.1.gz:May  4 17:06:04 merguez NetworkManager[1977]: <info>  [1777928764.7400] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.1.gz:May  5 19:58:40 merguez NetworkManager[1995]: <info>  [1778025520.7352] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.3.gz:Oct  9 15:25:31 merguez NetworkManager[8586]: <info>  [1760037931.7152] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.3.gz:Oct 13 20:48:04 merguez NetworkManager[3631]: <info>  [1760402884.2840] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.3.gz:Oct 17 15:30:24 merguez NetworkManager[13794]: <info>  [1760729424.0976] hostname: static hostname changed from (none) to "localhost"
/var/log/syslog.3.gz:Oct 17 15:49:31 merguez NetworkManager[15170]: <info>  [1760730571.1947] hostname: static hostname changed from (none) to "localhost"
```

But I've never _actually_ had the hostname change once OpenRC set it from
`/etc/hostname` until today! What?!

Clearly some combination of recent changes activated the same issues present in
that blog article, but symptoms had been around for a while. Notably, by
comparison with `last | grep boot`, I knew this wasn't happening on every boot
up. How bizarre…

Finally, I stumbled on [the Gentoo wiki for
NetworkManager](https://wiki.gentoo.org/wiki/NetworkManager#Hostname_problems),
which gives 2 options:

1. Prevent NM from touching the hostname.
2. Duplicate the value in `/etc/hostname` to `/etc/conf.d/hostname`.

Well, (2) is for the OpenRC script that's been working successfully all this
time anyway, so apply (1) and restart NetworkManager. Hoho, it's no longer
automatically touching the hostname!

Now, upgrade and restart: still viable. Ok, reboot?

Problems are gone… phew!

The fix looks like this in `/etc/NetworkManager/conf.d/hostname.conf`:

```
[main]
plugins=keyfile
hostname-mode=none
```
