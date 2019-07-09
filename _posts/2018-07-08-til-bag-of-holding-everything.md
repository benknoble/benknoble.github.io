---
title: Bag of Holding (Everything)
tags: [ til, infra, intern, rpg, make, python, "call of cthulhu", d&d-5e ]
category: Blog
---

You never know what you might pull out…

> This post contains the amalgam TIL for Thursday & Friday of last week. When I
> returned home Thursday from a Call of Cthulhu session, it was late and I was
> tired. Friday I was burnt out. Enjoy.

## Today I Learned

1. RPGs have lots of elements
2. The difference between python2 and python3, and how to make 2 look like 3
3. `make` syntax
4. Productivity requires feeling productive

## Elementals and RPGs

As you might have gathered from the tags and the note, I went to a _[Call of
Cthulhu][]_ 7e session Thursday night. Before you ask, no, _CoC_ does *not* have
elementals (but _[Dungeons & Dragons][]_ does).

_CoC_ takes its inspiration from Lovecraftian horror, an entire genre based on
books by H. P. Lovecraft himself. Even the [Evil Dead][] film references the
Necronomicon, an artifact that can be encountered in the game. Typical
'scenarios', run by the 'keeper', revolve around a mismatched team of unlikely
investigators who steadily uncover a horrifying and insanity-inducing truth.
While runnable in any setting, the game is strongly designed for the 1920s.

The reason I'm filing this under "TIL" is that, while I've been itching to try
_CoC_ for some time, I'd never actually done. I recently joined the [Raleigh
Tabletop RPG][] group on [Meetup][] to find games and people while I'm in town,
and this was my first experience with them.

Fortunately, I learned that RPG elements transfer over somewhat easily. Skills
like roleplaying go anywhere, while mechanics like stats and skill rolls might
change or disappear. Overall, though, the experience is fairly translatable.
Much like languages, learning one unlocks the potential to learn others.

In one night, I
- met a woman from Germany and a Frenchman
- collaborated to solve a murder/theft double-mystery
- went insane (but survived)
- had a lot of fun

It's up to you to decide what happened in character and what out.

This Wednesday, I'm joining some others for a little _D&D 5e: Rage of Demons_
action--I'll put together a post on my new character for that soon. And Thursday
will be _Kobolds Ate My Babies_, so look forward to some hilarity.

## Snakes, Versions, and the Future, Oh My!

I'm starting to design the implementation of [that caching system][cache] from a
little while ago, and it's been one heck of a doozy for my head. One thing was
for sure, though: I needed python.

Unfortunately, for our systems, that would be python 2.

So, like any good explorer, I set out to learn the differences. Being used to
python 3, I wasn't sure what I was getting into, but I knew it would make me
cringe. Fortunately, [this guide][python] has done most of the explaining to me.
It also showed me that I don't have to give up everything. `print` can still be
a function, with the use of the `__future__` module.

By the way, that caching spec has undergone some internal changes since the
first draft, so the one I linked is no longer the most current.

## Showing Off Your Recipes with `make`

Remember how, [way back when][make], I got to talking about `make` and it's
craziness? Well, one of the things I spent cycles on last week was re-learning
it. `info make` is a great reference, but the order they present things in
leaves a lot to be desired, so there was some tedious cross checking going on.

Anyways, regarding the multi-line syntax thing, there is a directive `.ONESHELL`
that can help avoid that. Cool beans.

## Production Junction, What's My Function?

And here's some more words. You guys got lucky, I was going to stop at 500, but
this makes about 624.

Friday, it was difficult to feel productive because my builds were still blocked
(yes, again), and I was spinning my head in circles trying to understand the
code that would go into the cache that I designed. Well, ok, so that code is
mostly straightforward, but I didn't quite grasp how it fit into our current
build system, which is mostly an abuse of `make`.

Fortunately, I now understand what I'm doing. But the road to get there taught
me something: if I don't feel like I'm actively being productive all day, I will
be sorely burnt out by the end of the day. And then I'm just not productive at
all.

Lesson learned.

_P.S._ I didn't use any emoticons today. :+1:

[Call of Cthulhu]: https://en.wikipedia.org/wiki/Call_of_Cthulhu_(role-playing_game)
[Dungeons & Dragons]: https://en.wikipedia.org/wiki/Dungeons_%26_Dragons
[Evil Dead]: https://en.wikipedia.org/wiki/Evil_Dead
[Raleigh Tabletop RPG]: https://www.meetup.com/Raleigh-Tabletop-Roleplayers/
[Meetup]: https://www.meetup.com
[cache]: {% link _posts/2018-07-03-til-day-11--third-times-not-always-the-charm.md %}
[python]: http://sebastianraschka.com/Articles/2014_python_2_3_key_diff.html
[make]: {% link _posts/2018-06-20-til-day-three-slacking.md %}
