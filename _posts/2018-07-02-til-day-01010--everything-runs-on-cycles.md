---
title: Day 01010--Everything Runs on Cycles
tags: [ til, infra, intern, vm, ssh, github, git ]
category: Work
---

$$A \to B \to C \to A \to \cdots $$

## Today I Learned

1. About clustering VMs in Hypervisor
2. A trick for using ssh keys with a personal and corporate GitHub account
3. To properly cycle

### :sunglasses: Hypervisor

So, in my [spare time](#round-and-round-again), I have a task for our Raleigh
lab to [cluster our DHCP server][cluster], which runs on a VM, so that if it
goes down we have an easy backup already running. This was new technology to me,
but a familiar concept (*redundancy*). The first step was the "R" in "R&D":
research.

So I spent today putting together a document on the basics of accomplishing the
above, what questions I still had, and what challenges we might face.
Unfortunately, I can't share it with you.

So have [IBM's][ibm].

## Keys :key: and Locks :lock:

I'm really sorry about the emoji. I seem to be on a thing today. We'll break up
tomorrow.

Anyhoo, as I was saying, [GitHub][]. `ssh`. Right, so I have this whole [Dotfiles][]
repository on [GitHub][]. And it actually was really easy to set up the second
time on my new Ubuntu machine. Only, (1) I configured `git` to use my Nuage
name & email for git commits, leading to (2) I edited my Dotfiles internal
`.git/config` to have my personal information, and (3) had to put in my GitHub
password every time I pushed!

I suffered that for a whole day longer than I thought I would (Friday). Today, I
had had enough.

As it turns out, `~/.ssh/config` is your friend here. This is especially true in
my case, where our corporate credentials are for a server Enterprise GitHub, so
the hostname is completely different. But you can use the same trick for
multiple regular accounts. Comments follow.

```bash
# change this if you want to use 'me.github.com' for a personal account in
# your `git clone` urls
# e.g., git clone git@me.github.com:benknoble/Dotfiles
Host github.com
  # HostName github.com
  # Uncomment the above line if the Host and HostName aren't the same
  # Think of Host as 'command line shortcut' and HostName as 'real URL'
  IdentityFile ~/.ssh/path/to/personal/public/key

# change this if you want to use 'corp.github.com' for an enterprise or
# secondary account in your `git clone` urls
# e.g., git clone git@corp.github.com:benknoble/Dotfiles
Host github.corp.domain.com
  # HostName github.fullurl.com
  # Uncomment the above line if the Host != HostName for corp
  IdentityFile ~/.ssh/path/to/enterprise/public/key
```

This assumes you have created and registered separate public keys with the
appropriate accounts using `ssh-keygen` and GitHub settings.

You'll note some of the comments about `Host` and `HostName`--this is why it's
easiest if one is a full on Enterprise GitHub. I can just use `Host` and my
clone urls over ssh will work. If you needed multiple `github.com` profiles, you
would have to set `HostName` to `github.com` in each one.

One final word on keys: you'll need to update any remotes on current projects to
use ssh urls.

## Round and Round Again

I planned to do a whole thing here, but I've moved it to the feature. Expect it
on Friday (or early, if I'm feeling generous).

[ibm]: https://www.ibm.com/support/knowledgecenter/en/SSDV85_4.1.0/Admin/concepts/part_hypervisors_cloud.html
[Github]: https://github.com
[Dotfiles]: {{ site.data.people.benknoble.github }}/Dotfiles
[cluster]: {% link _posts/2018-06-25-til-week-2--refactoring.md %}#dhcp-clustering
