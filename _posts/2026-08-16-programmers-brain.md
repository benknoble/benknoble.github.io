---
title: Thoughts from Felienne Hermans' "The Programer's Brain"
tags: [ software-engineering, git, refactor ]
category: [ Blog ]
---

A few notes from reading a recent section of the book.

I'm not quite finished, and I think I "discovered" a significant portion of the
early sections for myself by teaching myself to program. After the recent
section, I wrote down a few reminders for myself.

## Leave comments in code while exploring

I often use Vim's Quickfix list via commands like `:grep`, Fugitive's `:Ggrep`,
and more to search through a codebase and browse related code. I also jump to
definition via LSPs and Universal Ctags. I _also_ find related code through [Git
searches]({% link _posts/2026-06-23-git-log-S-performance.md %}).

Anyway, there's usually a mental "stacking" effect as I browse the code; after
reading some section and coming to some insight about how it works or how it
affects what I care about, I often leave a small split open with that section
and continue navigating in yet another window. I'm holding in my head the
insight I just came to, trying not lose it.

A quick aside: I believe that, while flow time is immensely valuable, maligning
the negative effects of interruptions masks laziness in argumentation.
Interruptions aren't great, sure, but we should all practice habits that
cheapen interruptions so that we can be better prepared to engage fruitfully
with our colleagues. That means externalizing the context we build up
internally!

So, holding those insights in my head doesn't play well with imminent eruptions
or, more generally, _cognitive load_.

Hermans advises us to leave comments in the code when we derive such insights!
For example, "saw this while Xing Y" or "I think this does…"

I used to hesitate to do so, since it isn't usually the goal for the changes I
plan to submit. But I don't hesitate to create preparatory or "while at it"
commits when doing my main work that fix _code_. Why not also "comment complex
reasoning" for others? Heck, Git means I will have the opportunity to decide to
keep or throw away later, so there's no reason to fear such comments.

## Refactor to understand and explore code

This is a lesson from early in the book that surfaced late, I think.

The idea is that, to understand code, we need to play with it. (I certainly
require this to develop _fingerspitzengefühl_.) One way to do that with existing
code is to refactor it into a shape I know.

Much like the above, I have hesitated to do this. The working copy feels
"sacred" to me, for some reason, in some contexts (why? I really need to pin
that down) but not in others. Despite my Git fluency, some while-at-it changes
are fine for me and others not.

I'd like to practice exploratory refactoring more. I'll probably throw most of
it away over time, but every now and then I might come up with a nugget worth
keeping.
