---
title: Renewing Tailscale-provided Certificates
tags: [ linux, tailscale ]
category: [ Blog ]
---

A quick note on Tailscale-provided SSL certificates.

Tailscale provides certificates through the ACME protocol with [Let's
Encrypt](https://letsencrypt.org). Their [current
policy](https://letsencrypt.org/docs/cert-lifetimes/) recommends frequent
automatic rotation within the 90-day window, and in 2028 we'll have a 45-day
window.

So, one might think to set up a cron job like

```
%monthly * 0-5 4-6 cd /etc/nginx && /usr/bin/tailscale cert <host>
```

to trigger a rotation near the beginning of each month. Nice and automatic, and
works for the 45-day window, too, right?

Well, the first time my such job ran, I got

```
Public cert unchanged at <host>.crt
Private key unchanged at <host>.key
```

What?

It turns out that [even after some changes in certificate
renewal](https://github.com/tailscale/tailscale/issues/8204), Tailscale waits
for Let's Encrypt to say it's a good window for renewal and then queues a
background job to update the cert! Thanks to [the Let's Encrypt community
forum](https://community.letsencrypt.org/t/tailscale-certificates/198895/21) for
pointing me to that information.

So I've now settled on a weekly job:

```
%weekly * 0-5 /root/renew-cert
```

that runs a simple script:

```shell
#! /bin/sh

cd /etc/nginx || exit 1
/usr/bin/tailscale cert <host>.net >/dev/null 2>&1 || {
  err=$?
  echo 'failed to renew certificate'
  exit $err
}
```

The output is for my email, since I let cron email me output. (Apparently that's
antiquated now?)
