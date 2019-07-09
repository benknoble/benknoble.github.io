---
title: ':tada: Announcing the release of loner! :tada:'
tags: [ github, scala, ebnf, ll-one, grammar, tdd ]
category: Release
---

I am pleased to announce the release of version 0.1.0 of [loner][loner]! You can
find its online documentation at [Junk Drawer/loner][loner-site], with a link to
the online API reference.

## What is it?

Loner aims to be a scala API and DSL for EBNF grammars. To explain those
acronyms:

  - *API*: application programming interface; a library of re-usable code
  - *DSL*: domain specific language; a mini-language suited to a specific need
  - *EBNF*: [the language of (context-free) languages][might]

## What does it do?

In short, it allows you to write code like (making use of implicits):

```scala
val grammar = Grammar(
  'A ::= "abc".? || 'B,
  'B ::= 'C.*,
  'C ::= "c" ~ 'A
)
```

Which is equivalent to parsing the following grammar:

```
# A is an abc or a B
<A> ::= ["abc"]
        | <B> ;
# B is 0-or-more Cs
<B> ::= {<C>} ;
# C is a c followed by an A
<C> ::= c<A> ;
```

Which loner can do for you! From scala,

```scala
val grammar = EbnfParser(
"""
# A is an abc or a B
<A> ::= ["abc"]
        | <B> ;
# B is 0-or-more Cs
<B> ::= {<C>} ;
# C is a c followed by an A
<C> ::= c<A> ;
"""
)
```

Finally, this first version provides a command line tool named `ebnf` that can
format such input (called ebnf files), stripping out the comments and produce a
machine-consumable output.

The aim is to eventually feed this into a `loner` tool that verifies that the
grammar is LL(1) compliant, a subject for another day.

## Why is this needed?

First, playing with languages is fun.

Second, the modern programmer will eventually find him/herself in need of a
mini-language, and want to write a grammar for it. Having a common way to do so
improves communication and creates an opportunity for new tools that operate on
these grammars (e.g., verify that a string is in the language, or manipulate the
grammar to try and reduce it, or generate random strings in its language, or any
number of other concepts: imagine allowing users to embed a language in your
next game just by writing a grammar specification and a mapping from constructs
to actions).

Third, the LL(1) property of context-free languages is important to development
tools for mini-languages, like the venerable `yacc`. Being able to readily
verify from the start that your language conforms is a time-saver; being able to
feed this input to a tool which could generated a `yacc` skeleton would be a
great boon.

## How?

`loner`'s first step was to build a model of a Grammar object. A grammar is
naturally a sequence of productions, each of which is a nonterminal symbol and a
rule (or expression).

The expressions naturally model as an abstract syntax tree, something scala's
case classes express readily. That, combined with their ability to give DSL-like
syntax as above, and my desire to implement a serious project in scala, combined
to make this project a reality.

To create the parser, `loner` makes use of scala's amazing parser combinator
library to derive a set of functional parsers for the components of the grammar,
each of which maps a part of the ebnf file into domain level objects above.

To be sure, this was not easy: scala's `RegexParsers` do not handle
left-recursion natively, forcing me to thing about how to stratify a grammar
(that, incidentally, described a language of grammars... how very meta). Adding
support for comments proved equally tricky, and `loner` does not (yet) support a
quoting or escape mechanism to embed special characters in non-terminals and
terminals. I also had to get over the hurdles of working with sbt and its many
oddities.

Finally, the Grammar objects provide a format method that does the work of
prettifying the grammar for output.

Loner employs a TDD-style development process, making use of `ScalaTest` to
express high-level expectations.

## Future?

As stated above, work is underway to develop a `loner` tool to verify the LL(1)
property of a grammar. This was the impetus for the project, as the algorithm to
verify this property is expressed so mathematically that it seemed naturally a
good fit for a language like scala.

## How can I help?

Use the code! Read it, help improve the documentation, report bugs, etc.

Dive in to our issue tracker, and see if there's something you can help with
(pesky escape characters...).

Write more tests (we'll never have perfect coverage).

I would love someone to contribute a vim-plugin for `.ebnf` files, complete with
filetype-detection, syntax highlighting, and support for `ebnf` as the indent
program. It's on my todo-list.

[loner]: {{ site.data.people.benknoble.loner }}
[loner-site]: {{ site.url }}/loner
[might]: http://matt.might.net/articles/grammars-bnf-ebnf
