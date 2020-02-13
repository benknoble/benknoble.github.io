---
title: 'Re: Coding the Impossible: Palindrome Detector with a Regular Expressions'
tags: [ rants, advice, learning, college, grammar ]
category: [ Blog ]
---

[Another internet
post](https://medium.com/analytics-vidhya/coding-the-impossible-palindrome-detector-with-a-regular-expressions-cd76bc23b89b)
sparks a small rant.

(This is a follow-up of my previous article on the [Fundamentals of
Computation]({% link _posts/2020-01-14-cs-fundamentals.md %}).)

## Do you remember?

Earlier, I ranted about the apparent lack of education regarding the
fundamentals of what is computable: certain tools are not powerful enough for
certain problems, and some don't seem to know this (or don't care).

Well, the brave Tony Tonev decided to try to bend the rules a bit.

### A man, a plan, a canal, Panama!

Technically, Tony succeeded at what he set out to do: check for palindromes
using regular expressions. This is a rather interesting achievement, since
palindromes are generally considered context-free. So, how can this be?

Let's break down the main issues:

- Tony claims:

> technically [that StackOverflow user is] right for arbitrary-length
> palindromes, but that doesn't mean we can't make one for palindromes up to a
> maximum length

Ok, this is *technically* true, but the resulting DFA (or even NFA) would be
humongous for even a short maximum-length over the English alphabet! With length
2, we already have $$26^2 = 676$$ states (one for each combination of letters),
and then only 26 of these are accepting! Imagine the resulting exponential
blowup for bigger palindromes…

If you're wondering if this is even feasible, remember that Tony's goal has
length 22 (not including whitespace). Fortunately, the astute Tony notes that we
have far easier ($$O(n)$$) methods of detecting palindromes.

- Next, Tony says:

> I wrote a regular expression which detects palindromes up to 22 characters
> ignoring tabs, spaces, commas, and quotes

And then he gives a bunch of text. Since he says regular expression, we are left
wondering what he means. It can't be a classical CS RE, since it's not using set
operations or the like. It *appears* to be a PCRE (Perl-Compatible RE), due to
it's use of the `(?:)` non-capturing group and back-references---but wait just a
minute! [PCRE is famously far more powerful than a classical
RE](https://catonmat.net/perl-regex-that-matches-prime-numbers)! And
back-references are a core too-big-for-RE feature!

Well, is it really PCRE?

- Tony says:

> Nope, it's actually a valid regex. Feel free to check it using regexr.com,
> which is an awesome tool to instantly see the results of your regex's [sic]
> and explains what each part does.

Wait, regexr.com? Ok, let's check that out…

> Supports JavaScript & PHP/PCRE RegEx.

So, PCRE after all, eh? Well, Tony, you sure pulled the wool over our eyes
there…

### Who cares?

Hopefully, it's obvious that Tony is smart, and I'm not really angry with him.

Hopefully, it's obvious I'm not aiming for a gate-keeping, "only real
programmers" approach.

But hopefully it's equally obvious that terminology matters. This isn't "solving
palindromes with RE"---it's "solving palindromes with something vastly more
powerful than RE." Can the problem be solved with an RE? Yes. Does it lead to
exponential blow-up, since REs don't actually have back-references? Also yes.

Tony, next time, please be more careful with your terminology. This is the kind
of imprecision that keeps the "REs can do anything" myth alive.
