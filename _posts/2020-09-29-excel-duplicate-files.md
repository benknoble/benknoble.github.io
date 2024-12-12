---
title: 'Excel for Mac cannot simultaneously edit files with the same basename'
tags: [ rants, ms-excel, ]
category: [ Blog ]
---

Yes, you read that right: you can't open (_e.g._) `Documents/budget.xlsx` *and*
`Work/budget.xlsx` at the same time.

## What the f@#$?

Yeah, that was my reaction, too. At first, it doesn't make any sense.

Here's the best explanation I have, as an educated programmer: the basenames
(that would be the `budget.xlsx` part---I haven't tested differing extensions
yet) are probably stored in a duplicate-disallowing structure. Normally, we'd
call that a set. I suspect they're probably actually keys in a map of filenames
to in-memory buffers of contents or data or some-such. The keys of a map must be
a set, so that would also track.

## Fix it!

I wish I could. Stupid closed-source bloatware… I mean, sure, it's a nice tool
for spreadsheets.

Ironically, the fix is probably easy: use absolute paths as the entries in
whatever this set is. I cannot fathom a single reason not to do so.

This might not solve the problem if two documents have the same absolute path on
two different file-systems (_e.g._, my hard drive and a network-mounted
file-share or some other storage medium), but we could either

- include the medium name in the entry, or
- include the mount point in the entry.

Again, what the f@#$.
