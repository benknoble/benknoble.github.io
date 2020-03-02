---
title: CS Students Must Learn Computation Fundamentals
tags: [ rants, advice, learning, college, grammar, clojure ]
category: [ Blog ]
---

Another internet post sparks a small rant.

## Problems & Solutions

Have you ever seen that [famous StackOverflow post about "parsing" HTML with
regular expressions](https://stackoverflow.com/q/1732348/4400820)?

This one cropped up today about [detecting balanced
parentheses](https://codereview.stackexchange.com/q/235597/123233): it's amusing
that the author converted to a correct approach only after the realization that

> performance was quite slow when any large string was passed to the regex

…while failing to acknowledge the true flaw in the original approach.

### Pop quiz

1. Parsing HTML with regular expressions is possible. (True or False)
2. Determining if parentheses are correctly balanced and nested is possible with
   a regular expression. (True or False)

Go read the linked posts, and see if your answer matches up.

Ironically enough, this post has sparked a lot of debate about whether it is
"sometimes, sort of, mostly" OK to "parse" HTML with a regex. The argument is
that "it worked for me this one time, it's not production code, it's a quick
hack, so no harm no foul." *And I mostly agree.* But it's not parsing.

## All CS Students Must Learn the Fundamentals of Computation Theory

I like the text *Elements of the Theory of Computation* by Lewis &
Papadimitriou. It was used in my Comp 455 (Models of Languages & Computation).

Any student with this knowledge should know that language of balanced
parentheses is context-free! It can *never* be decided with a regular
expression: given any regular expression $$e$$, there will always be a string
$$s \in \text{BalancedParens}$$ such that $$s \not\in \mathcal{L}(e)$$!

Students would be better programmers, and better equipped to reason about
programs, if they knew what was achievable with certain formulations: and
moreover, what was *not*.

In the case of balanced parentheses, we need a computer with power to decide at
least context-free languages. A PDA is one-such computer; in this case, we
effectively need a stack and a transition function.

I won't give the entire formal description here (unless someone really asks for
it), but I've coded a reference implementation in Clojure to keep with the theme
of balanced parentheses.

{% gist f6d157217a7a814450d6fc9cf45625ee %}
