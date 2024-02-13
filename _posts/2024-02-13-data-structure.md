---
title: 'A Strategy to Change Core Data Structures in Programs'
tags: [ refactor, advice, racket, frosthaven-manager ]
category: [ Blog ]
---

This relates to the refactoring rule "Make the change easy, then make
the easy change" from Kent Beck. He warns that the first step may be hard. I
present one strategy to make the first step easier for data structure
changes.

It sounds so simple when you say it out loud: change either the data structure
or the data-processing programs, one at a time.

## Motivation

Imagine you have a data structure that maps decks of cards to numbers as a core
piece of a program. This represents some way of constructing a mixed deck by
drawing cards from each of the decks. Naturally you have some programs that
manipulate this data. You might have
- a program to convert the mapping into a mixed deck
- a program to update the mapping
- a program to display the mapping in a graphical interface
- etc.

Now suppose you need to make a change to support enhancing specific cards in the
decks.

You could make this change by adding a program to update the mapping by finding
the deck, converting it to a new deck with the enhanced card, and swapping the
key (keeping the old value). Let's say that poses several challenges and has
some negative trade-offs.

Another way to solve the problem is to split your data structure into 2 pieces:
- a mapping from card _types_ to numbers (how many cards of that type in the
  mixed deck)
- a mapping from card _types_ to decks (what deck to draw from)
See, each relation in the original mapping had an implicit 3rd component: the
type of cards in the relationship. With this split, the programs above need
changes. The program to enhance cards need only update the second mapping to
point to an enhanced deck, though, and is simpler to reason about.

How do you make this change incrementally (with small, focused commits) and keep
your tests passing?

In case the benefits of this approach aren't obvious:
- Small focused commits makes review easier. Large commits are hard to reason
  about.
- Passing tests at all commits increases my confidence that I'm not breaking the
  system as I make changes.
- I also have to keep less in my head at a time, and have a cleaner pause point
  if I need to take a break or to deal with an interruption.

## The 2-part Strategy

1. Change either the data structure _or_ the contract of all the programs that
   manipulate it. Add adapters as necessary.
2. Change the other.

Changing everything at once is hard. [In a recent merge, I changed the programs
first and then split the
data](https://github.com/benknoble/frosthaven-manager/commit/11494ba86888ef84901def135c26656410abcbc8).
The full diff looks quite large, but [the individual commits in that
range](https://github.com/benknoble/frosthaven-manager/compare/feca028...3c56606)
are quite focused.

Let's say you change the contract of the programs first. This means accepting
arguments for the split data structures and manipulating those. It also requires
adapting the old data structure into the new ones somehow, so you'll end up with
code to convert old to new at the call-site. And everything should still work,
though you probably haven't written the enhancement program yet.

Now you can change the data structure, which allows you to throw away the
adapter code at call-sites because the new structures line up with the existing
contracts.

Finally, you can write the easy program you wanted to for enhancement.
