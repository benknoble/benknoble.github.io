---
title: Self-hosting Vaultwarden on Gentoo
tags: [ linux, open-source, gentoo, politics ]
category: [ Blog ]
---

After the [1Password announcement of Omarchy
sponsorship](https://www.theverge.com/tech/988536/1password-dhh-linux-controversy),
I took a hard look at alternatives.
[Vaultwarden](https://github.com/dani-garcia/vaultwarden) is easy to self-host
and gave me enough of what I needed.

At the end of this post, I'll include the email I sent to 1Password's customer
support and their response.

Vaultwarden is a [Bitwarden](https://bitwarden.com/)-compatible backend for
securely storing passwords, user data, other metadata that the official
Bitwarden clients (desktop, web, browser, mobile) use to implement a
1Password-like password manager. Bitwarden is not as pretty as 1Password, and
some things irritate me:

- no image uploads for users or organizations
- no "universal shortcut" for autofill

but the data lives on my machine (thanks to Vaultwarden) and the whole project
is [open source](https://github.com/bitwarden/). You can also self-host using
the official backend, but I'm more comfortable using Vaultwarden (which also
means I'm not paying for additional features).

## Notes for Gentoo

I have a [tailscale VPN](https://tailscale.com), so we'll use that for the
necessary HTTPS certificates and for exposing Vaultwarden to my devices securely
from my homelab. I run an nginx web-server, which will be the reverse proxy to a
local HTTP service. Gentoo already packages Vaultwarden with an OpenRC service,
so we'll use that instead of running a Docker container.

### Packages

First, emerge the following packages:

- `app-admin/vaultwarden`, with `web` and `sqlite` USE flags for sure, and I also
  have the `cli` flag
- `app-admin/bitwarden-desktop-bin`.

The `web` flag will pull in Vaultwarden's web client, which you'll probably need
to make user invites work well (invite emails have sign-up links that use the
web client whether or not it is installed).

You'll need to accept unstable keywords for these packages at time of writing
(`/etc/portage/package.accept_keywords/vaultwarden` for me):

```config
# servers
app-admin/vaultwarden
www-apps/vaultwarden-web

# clients
app-admin/bitwarden-cli-bin
app-admin/bitwarden-desktop-bin
```

### HTTPS

While that's running, get HTTPS certificates:
`(cd /etc/nginx && tailscale cert <host>)`.
We can also go ahead and add a crontab entry to renew our certs, which is [best
practice today](https://letsencrypt.org/docs/cert-lifetimes/). In
[fcron](http://fcron.free.fr/) syntax, running each month in the early morning
on the 4th, 5th, or 6th:

```
%monthly * 0-5 4-6 cd /etc/nginx && /usr/bin/tailscale cert <host>
```

### nginx

Now let's configure nginx. We need to enable our certificates, and we can also
go ahead and configure the SSL cache:

```nginx
http {
    ssl_session_cache shared:SSL:10m;
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        ssl_certificate     <host>.crt;
        ssl_certificate_key <host>.key;
    }
}
```

In this case, I'm hosting Vaultwarden on a *path* in my server, rather than
hosting multiple domains from this single server. So in the same server block,
I'll add a route for (_e.g._) `/vaultwarden/`:

```nginx
http {
    # …

    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      "";
    }

    # https://stackoverflow.com/a/67492000/4400820
    # https://serverfault.com/a/1046256
    map $request $custom_request {
        ~^(.*)([\?&]access_token=)([^&]*)(.*)$  "$1$2***redacted***$4";
        default                                 $request;
    }

    log_format no_jwt '$remote_addr - $remote_user [$time_local] '
        '"$custom_request" $status $body_bytes_sent '
        '"$http_referer" "$http_user_agent"';

    server {
        # …

        location /vaultwarden/ {
            # https://serverfault.com/a/772049
            if ($scheme = http) {
                return 308 https://<host>$request_uri;
            }

            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_pass http://127.0.0.1:<port>/vaultwarden/;

            access_log /var/log/nginx/vaultwarden_access.log.gz no_jwt gzip;
        }
    }
}
```

There's 3 main things going on here:

1. HTTP redirects to HTTPS. You don't need this, probably, if your server
   doesn't listen for HTTP traffic. I serve both on my VPN, since tailscale
   encrypts the connection anyway, but Vaultwarden won't work without HTTPS.
1. Reverse proxying with connection upgrades. See [the Vaultwarden
   wiki](https://github.com/dani-garcia/vaultwarden/wiki/Proxy-examples).
1. Custom logging format. The [Vaultwarden wiki](https://github.com/dani-garcia/vaultwarden/wiki/Hardening-Guide#access-logs-contain-access_token-parameter)
   explains that access logs contain a JWT token for WSS connections, and that
   should be redacted.

Also take note of which port you decide to `proxy_pass` to, as we'll need to
tell Vaultwarden to use the same one.

### OpenRC

We don't need to adjust the `/etc/conf.d/vaultwarden` at all.

We will adjust the `/etc/init.d/vaultwarden` script to set `output_logger` and
`error_logger`, which in retrospect might work in `/etc/conf.d` too? In
particular, I want Vaultwarden routed via `syslog`, and if we configure
Vaultwarden itself to use the syslog it [produces incorrect timestamps in the
logs](https://github.com/dani-garcia/vaultwarden/discussions/7721). So instead
add the following:

```shell
output_logger=logger
error_logger="$output_logger"
```

and we'll configure Vaultwarden to log via stdio.

### Vaultwarden

Finally we're ready to configure Vaultwarden itself via
`/etc/vaultwarden/vaultwarden.conf`. Make sure this file is readable only to the
`root` user and `vaultwarden` group (recent Gentoo installations should have
this correct, but the package [used to leave the config file loosely
permissioned](https://bugs.gentoo.org/show_bug.cgi?id=982150).

- If you want to enable push notifications, follow the instructions to get a key
  and ID from Bitwarden and enable `PUSH_ENABLED=true` along with the key/ID
  variables (these secrets are why we control access permissions!).
- You *must* configure `DOMAIN` as `https://<host>/<path>`.
- Following the hardening guide on the wiki, `SIGNUPS_ALLOWED=false` and
  `INVITATIONS_ALLOWED=false`.
- We turn on `EXTENDED_LOGGING=true` and set none of `USE_SYSLOG` or `LOG_FILE`
  to log extended data to stdio.
- Generate (and save) an admin password, then `vaultwarden hash` it for an
  Argon2 PHC string which goes in `ADMIN_TOKEN`. You'll need this to access the
  admin page for your instance.
- I use `nullmailer` to send emails through my existing Gmail account, so I
  only made `SMTP_FROM` my email address and `USE_SENDMAIL=true`. Your settings
  may vary.
- Finally, configure `ROCKET_ADDRESS=127.0.0.1` (localhost only) and
  `ROCKET_PORT=<port>`. The address *must* be an IP address; using `localhost`
  won't work.

With that, you should be able to `rc-service vaultwarden start`, see logs in
syslog, and go to your Vaultwarden endpoint (`/admin`) to get to the admin
console. From there you can invite your first user. When connecting new clients,
make sure to set the server address using your host/port combination.

You may want to check out additional [hardening guide
steps](https://github.com/dani-garcia/vaultwarden/wiki/Hardening-Guide), such as
configuring SNI, disabling password hint display, or setting up Fail2Ban
(although Linux gurus I trust are wary of letting attackers control firewall
rules via Fail2Ban).

If all is working, I suggest `rc-update add vaultwarden default`.

Future updates to the Vaultwarden package will require using `dispatch-conf` to
merge changes in.

Finally, backups. I already make nightly system backups, but we want to backup
the database specially to avoid getting an incomplete corrupt copy. I run a
single nightly database backup (again via fcron), and I haven't decided on an
automated pruning strategy yet, since my database and user-base are small:

```
%nightly * 21 ENV_FILE=/etc/vaultwarden/vaultwarden.conf /usr/bin/vaultwarden backup
```

It's important to set `ENV_FILE` or Vaultwarden won't find the database!

### Migrating from 1Password

Bitwarden understands 1Password export formats, so export from 1Password and
import to Bitwarden.

Things you'll have to do manually:

- Re-upload file attachments
- Move any "shared vault" items into a new organization vault that you create

### Desktop client

The Linux desktop client quits itself when I press <kbd>Ctrl</kbd>+<kbd>w</kbd>.
1Password would stick around in the system tray. The equivalent for Bitwarden is
<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>m</kbd>.

## Letter to 1Password

When [Duke University Libraries dropped Basecamp in 2023][1], it seemed
fairly obvious they were on the right side of history and their own
values.

[1]: https://blogs.library.duke.edu/blog/2023/11/30/why-were-dropping-basecamp/

As a long time 1Password customer (my current account dates to 2021,
but I've been using it since at least 2012), I am frankly disappointed
and mistrustful of the move to support OmaCom and related projects. I
know I am not alone among your customers.

1Password's stated mission is to "build a safer, simpler digital
future for everyone"—but folks like DHH repeatedly use exclusionary
rhetoric to espouse exclusionary visions of the world. 1Password wants
to give back "for good," but this donation is more likely to help what
some consider a grift by DHH than it is to help either 1Password's own
business interests or to contribute to community good. Even the
"Giving back in Toronto" program does not align with one of OmaCom's
funding members, Shopify’s Tobias Lütke, whom [the Verge cites as
supporting voting proportional to wealth in Canada][2].

One of these things is not like the other.

[2]: https://www.theverge.com/tech/988536/1password-dhh-linux-controversy

It seems to me, as a programmer and open-source advocate, that a far
simpler path to helping your customers (even if Omarchy is a huge user
base for you) would be to support foundational technologies. For
example

- Arch, on which Omarchy is built
- Linux kernel development, such as the security team
- various Linux desktop efforts for X, Wayland, accessibility, etc.
- the long list of shared libraries you link to
- the Rust foundation and related ecosystem

And, if you're already doing these things, it's not clear what
supporting OmaCom can do additionally. Certainly downplaying internal
concerns will not help either. An explicit _rejection_ of DHH's
positions seems called for, alongside specific and concrete action for
an equitable future (actions speak louder; right now, we weigh an
implicit endorsement against a denial of explicit endorsement—you can
see how an explicit rejection might help tip those scales).

My plan renews in February 2027. At this time, I must seriously
consider alternative offerings so that I may be prepared to let my
subscription lapse if I cannot bring myself to continue to trust
1Password's position and alignment with its own stated values.

## 1Password's response

Thank you for reaching out and sharing your concerns about our decision to
become a corporate patron of the Omacom Foundation. We value the relationship we
have with you, and we want to respond thoughtfully and openly about the purpose
of this commitment and how we're approaching it at 1Password.

At 1Password, we support developer and open-source communities because they're
an important part of the ecosystem our customers rely on. We have a long history
of supporting open source projects, including the Linux, Rails, and Rust
Foundations. We chose to support Omarchy because it is a growing Linux
environment that developers use and value, and because 1Password already had a
meaningful presence in that community.

Contributing to the Omacom Foundation is intended to support hosting
infrastructure and provides stable, long-term funding for the upstream
open-source projects and maintainers on which Omarchy depends.

We recognize that Omarchy is closely associated with its founder, and that
raises questions about what our support means. Our contribution is made to the
Omacom Foundation, not to an individual, and is not an endorsement of any
individual's personal or political views. 1Password does not endorse hateful,
dehumanizing, or exclusionary views.

The patronage is also separate from product decisions. It includes no
requirements or guarantees related to product placement, exclusivity,
endorsement, or roadmap influence.

We understand that this explanation may not change how you feel about our
decision. We take all feedback seriously and share it with the appropriate
teams. Our commitment to the security and privacy of our customers remains
unchanged.
