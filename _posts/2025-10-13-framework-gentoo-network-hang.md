---
title: 'Solving Network Hardware Hangs on Framework Desktop'
tags: [linux, network, gentoo]
category: Blog
---

I've recently installed Gentoo on my new Framework Desktop, and for a while the
network would hang, causing any program that touched the hardware to also crap
out.

Here are some symptoms:
- Thinks chug along just fine, until
- The network goes down and commands start freezing. We're talking no C-c, no
  C-\\, no `pkill -9`: just dead in the water. (I hadn't solved switching
  consoles with Alt-Function keys yet, so fortunately I had tmux running.)
    - Notably, commands like `emerge` hang when they get to network steps.
      Various `ip` & `ifconfig` style commands hang immediately.
    - Commands like `nmcli` and `ping` don't hang, but don't work.
    - I'm pretty sure `/etc/resolv.conf` isn't being touched.
- The `NetworkManager` daemon is running, but:
    - `top` shows "D" (d-sleep) and `ps` shows "Dsl"
    - `rc-status` reports NetworkManager as active, but `nmcli g` says its down
    - `rc-service NetworkManager restart` fails with

        ```
        * Caching service dependencies ... [ ok ]
        * Unmounting network filesystems ... [ ok ]
        * Stoppping NetworkManager ...
        * start-stop-daemon: 1 rocesses refused to stop [ !! ]
        * ERROR: NetworkManager failed to stop
        * Mounting network filesystems ... [ ok ]
        ```

    - similarly with `s/restart/stop`, and `pkill -9 NetworkManager` has no
      effect!
        - I didn't understand how `zap` worked at the time, so I wonder if that
          would have helped :thinking:
    - shutting down complains about not stopping the NetworkManager, too

I checked my hardware with `lspci`, which I'd fortunately installed during the
main system installation process, and with `lspci -k` I found out my network
card is

```
c0:00.0 Mediatek MT7925 (RZ717) Wi-Fi 7 160MHz [14c3:0717]
```

with kernel module (in use) `mt7925e`.

First, I tried turning off WiFi power saving [as recommended by Garuda folks](https://forum.garudalinux.org/t/mediatek-mt7925e-wifi-speed-very-slow-on-close-to-fresh-install-and-some-updates/41845/11):

```shell
printf '%s\n' '[connection]' 'wifi.powersave = 0' | doas tee /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf
```

That didn't help: a little while into my next reboot, the hang happened again.
Then I tried [disabling the "Active State Power Management" for my network
card](https://forum.garudalinux.org/t/mediatek-mt7925e-wifi-speed-very-slow-on-close-to-fresh-install-and-some-updates/41845/9),
which is apparently cursed with this problem:

```shell
echo 'options mt7925e disable_aspm=1' | doas tee /etc/modprobe.d/7925e_wifi.conf
```

That seems to have done the trick, so I'll delete the NetworkManager settings.

## A few unrelated (?) things

I don't have kernel logs for the problematic scenario, but now that my system is
running normally I can eliminate a few things from the problem space.

In both working and non-working configurations, I saw repeated logs in `dmesg`
for the network:

```
disconnect from AP <MAC> for new auth to <other MAC>
authenticate with <other MAC> (local address=<my MAC>)
send auth to <other MAC> (try 1/3)
authenticate with <other MAC> (local address=<my MAC>)
send auth to <2nd other MAC> (try 1/3)
authenticated
associate with <2nd other MAC> (try 1/3)
RX AssocResp from <2nd other MAC> (capab=0x1511 status=0 aid=3)
associated
Limiting TX power to 30 (30 - 0) dBm as advertised by <2nd other MAC>
diassociated from <2nd other MAC> (Reason: 1=UNSPECIFIED)
```

Often these occur every 5 minutes and loop for a while, then die away.

I saved some logs with
```
{ echo count from to;
  grep 'disconnect from AP' /var/log/messages |
    grep -o '\([[:xdigit:]][[:xdigit:]]:\?\)\{6\}' | paste - - |
    sort | uniq -c; } | column -t
```

which gave for example

```
count  from               to
3      <prefix>:2f:a9:51  <prefix>:2f:a9:59
22     <prefix>:2f:a9:51  <prefix>:d2:14:29
1      <prefix>:d2:14:21  <prefix>:2f:a9:59
2      <prefix>:d2:14:21  <prefix>:d2:14:29
```

As far as I can tell, the (masked) `<prefix>` there matches the output from
another connected device when checking the router with `arp -a`:

```
gr6exx0c-a940.lan (192.168.2.1) at <prefix>:2f:a9:40 on en0 ifscope [ethernet]
```

And my management app says
- the router has a MAC of `<prefix>:2f:a9:41`
- the extender (MoCA) has a MAC of `<prefix>:d2:14:10`

So clearly something is going on here, and the NetworkManager is having trouble
deciding which connection to use?

## Miscellany

- `dmesg -Hw` is much nicer than regular `dmesg`
- `shutdown -hP` didn't power off, but `reboot -p` did reboot
- `lspci -k >/dev/null` complains:

    ```
    pcilib: Error reading /sys/bus/pci/devices/0000:00:08.3/label: Operation not permitted
    ```

    but running with usual output doesn't.
- Once I saw dmesg logs about my SSD?

    ```
    block nvme0n1: the capability attribute has been deprecated
    No UUID available providing old NGUID
    ```
- Related:
    - [https://community.frame.work/t/framework-13-amd-ai-wifi-issue-on-arch-linux/71019/2](https://community.frame.work/t/framework-13-amd-ai-wifi-issue-on-arch-linux/71019/2)
    - [https://forum.garudalinux.org/t/mediatek-mt7925e-wifi-speed-very-slow-on-close-to-fresh-install-and-some-updates/41845/6](https://forum.garudalinux.org/t/mediatek-mt7925e-wifi-speed-very-slow-on-close-to-fresh-install-and-some-updates/41845/6)
    - [https://bbs.archlinux.org/viewtopic.php?id=300490](https://bbs.archlinux.org/viewtopic.php?id=300490)
