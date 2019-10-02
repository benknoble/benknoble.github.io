---
title: 'Re: How Did Perl Lose Ground to Bash?'
tags: [ perl, shell, prog-langs ]
category: [ Blog ]
---

Spoiler: Because I don't *need* or *use* Perl everyday

## [Original post](https://www.reddit.com/r/perl/comments/d2yix0/how_did_perl_lose_ground_to_bash/?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed%3A+PerlWeekly+%28Perl+Weekly+newsletter%29)

This was the original post as accessed on the 26th of September, 2019. All
quotes are from that day, approximately 22:30 EDT.

> Setting aside Perl vs. Python for the moment, how did Perl lose ground to Bash?
> It used to be that Bash scripts often got replaced by Perl scripts because Perl
> was more powerful. Even with very modern versions of Bash, Perl is much more
> powerful.
>
> The Linux Standards Base (LSB) has helped ensure that certain tools are in
> predictable locations. Bash has gotten a bit more powerful since the release of
> 4.x, sure. Arrays, handicapped to 2-D arrays, have improved somewhat. There is a
> native regex engine in Bash 3.x, which admit is a big deal. There is also
> support for hash maps.
>
> This is all good stuff for Bash. But, none of this is sufficient to explain why
> Perl isn't the thing you learn after Bash, or, after Bash and Python; take your
> pick. Thoughts?
>
> ---u/s-romojosa

### A first glance

It may be true that the core language of Perl is more powerful (with or without
CPAN)---there are more language features, more powerful constructs, etc. Bash,
on the other hand, is relatively simple at its core. But to restrict Bash to
while loops and a pipeline includes its biggest weakness and its biggest
strength, while ignoring practically every other good thing about it.

I'll come back to the weakness, but I want to clarify: pipelines are Bash's
strength. They are function composition. They are what enable me to rapidly
filter and process data in whichever way I like---wait, no, that's not right.
*Pipelines* enable me to combine tools! That's function composition. But what
would a `|` be without a tool on either side?

To ignore that Bash is a shell fundamentally built to compose *other tools*
(`grep(1)`, `sed(1)`, and `awk(1)` among the most popular, but `cut(1)` and
`paste(1)` and even `jq(?)` too)---in other words, to ignore that Bash is very
nearly a *meta*-language, is to ignore its true power.

### Some nits

> Arrays, handicapped to 2-D arrays, have improved somewhat

What is the author talking about? I've never seen a 2D array in Bash. The array
types are "one-dimensional indexed and associative" (`bash(1)`).

> […] hash maps

They're called associative arrays---I'm concerned the author doesn't understand
Bash! To be fair, I barely understand the deepest parts of Perl. But I
understand hashes in Perl, and would expect someone asking this question to
understand associative arrays in Bash. Core language features...

> […] native regex engine in Bash 3.x, which admit [sic] is a big deal

Actually, it is not that big a deal. The first three tools I mentioned all deal
in regex. So do many more. Bash's native engine is good for its capture groups:
but then, I should ask you---if you find yourself needing capture groups, what
are the chances you're going to process the captured data later? And what are
the odds there is a better, perhaps more efficient, solution---one which uses a
pipeline?

(Remember [my post]({% link _posts/2019-08-14-cstat-efficiencies.md %}) about
pipelines?)

### Sample of responses

I'm going to take a moment to address some of the responses in the same vein as
I did with the OP, because I think some of them missed at least part of the
mark.

> Because Perl has suffered immensely in the popularity arena and is now viewed
> as undesirable. It’s not that Bash is seen as an adequate replacement for
> Perl, that’s where Python has landed.
>
> ---u/oldmanwillow21

I don't think this fully explains why *I* don't use Perl. I've never needed to.

Let me give you a simple problem: write a function that, given some data
(however you want input: stdin, arguments, whatever), computes the frequency of
each piece. That is, compute (return, output, etc.) a mapping between the
elements of the data and the count of how many times that element occurred.

Go ahead. I'll wait.

In bash, it's one line: `frequency() { sort | uniq -c ; }`. Hell, just for fun,
I sorted the results again: `frequency_sorted() { sort | uniq -c | sort -g ; }`.

It's simple. It's understandable. It's built on composition.

I'm sure there's at least one language where it amounts to `data.counts()`, but
can I pipe in anything I want from the shell to it?

Further examples:

```bash
# most recent commands
recent() {
  hisotry | cut -c8- | cut -d" " -f1 | frequency_sorted | sort -rn | head
}

# mode
mode() { frequency_sorted | head -n 1 ; }
```

It would have taken me longer to write `frequency` in Perl than all three of
these together, and then I'd still have to figure out how to get my data into
it.

So I use Bash because it does exactly what I need---I don't need to reach for
fancy objects to do this kind of manipulation.

**Please post your Perl (or other) attempts in the comments.**

> I'd add to this, it's because no real competitor has emerged for Bash.
>
> ---u/Grinnz

Doubtful: what about Zsh, Fish, and the host of others? Again, I don't think
this is the real reason Bash is popular.

At least one point remains: Bash was default on macOS until recently. It is
(was?) default on other Linux distros as well.

> How did Perl5 lose ground to anything else?
> Thusly
> - "thou must use Moose for everything" -> "Perl is too slow" -> rewrite in
>   Python because the architect loves Python -> Python is even slower ->
>   architect shunned by the team and everything new written in Go, nobody dares
>   to complain about speed now because the budget people don't trust them ->
>   Perl is slow
> - "globals are bad, singletons are good" -> spaghetti -> Perl is unreadable
> - "lets use every single item from the gang of four book" -> insanity -> Perl
>   is bad
> - "we must be more OOP" -> everything is a faux object with everything else as
>   attributes -> maintenance team quits and they all take PHP jobs, at least
>   the PHP people know their place in the order of things and do less
>   hype-driven-development -> Perl is not OOP enough
> - "CGI is bad" -> app needs 6.54GB of RAM for one worker -> customer refuses
>   to pay for more RAM, fires the team, picks a PHP team to do the next version
>   -> PHP team laughs all the way to the bank, chanting "CGI is king"
>
> ---u/emilper

Aha, so emilper wants to talk about larger systems? Systems where we need
objects and classes and design patterns? I'm not saying you *can't* do this in
Perl. But why not do it in a language where this stuff is baked in? OOP in Perl
is kludgy---it would be in Bash too, if someone did it. And we'd all say "Wow,
that's cool, but I can't use it because no one would understand what the hell I
was doing or why." We'd go back to Java, C#, Smalltalk, Ruby, Python, or a Lisp
or ML or Haskell. And we'd be happier. Because those languages are fundamentally
designed to do larger systems, better.

I'm not writing OOP, CGI, or large systems in Bash. I'd challenge anyone who is
to rethink their design.

My longest (in lines) scripts in my Dotfiles are:

```bash
# wc -l $(ack -f --shell) | sort -rg | head
    2009 total                            # total lines
     196 links/bash/PS1.bash              # builds my prompt
     193 links/bashrc                     # part of my startup config
     123 links/bin/git-overwritten        # oh, an actual script that does some text processing
     102 links/bin/java-update-mfile      # and another!
```

The real scripts are on the order of 100 lines.

The smallest?

```bash
# wc -l $(ack -f --shell) | sort -g | head
       2 links/bash/linux/clipboard.bash
       4 links/bash/jobs.bash
       5 links/git_template/hooks/post-checkout
       5 links/git_template/hooks/post-commit
       5 links/git_template/hooks/post-merge
       6 links/bash/overrides.bash
       7 links/bash/sysadmin.bash
       7 links/git_template/hooks/post-rewrite
       8 links/bash/mac/sysadmin.bash
      10 links/bin/brew-superclean
```

Just, wow. Now, let's take a look at the frequency of lines. The format is
(count lines):

```bash
# wc -l $(ack -f --shell) | G -v 'total' | fields 1 | frequency
   1 10
   1 102
   1 12
   1 123
   1 13
   1 15
   1 17
   1 193
   1 196
   1 2
   1 20
   1 24
   1 26
   1 27
   1 29
   1 32
   1 4
   1 43
   1 45
   1 49
   1 50
   1 59
   1 6
   1 62
   1 8
   1 82
   1 85
   1 86
   1 98
   2 14
   2 16
   2 28
   2 68
   2 7
   3 11
   3 18
   3 41
   3 5
```

(`G` is a `grep(1)` function, and `fields` I wrote about previously.)

Anyone want to build a histogram for me? Say, bucketed by 10?

**Edit 28th September**: I got close with `awk(1)` (`A`), and formatted by
(lines, count):

```bash
# wc -l $(ack -f --shell) | G -v 'total' | fields 1 |
#   A '{ printf "%d\n", sprintf("%1.0e", $0) }' |
#   frequency | fields 2 1 | sort -g |
#   A '{ printf "%d\t", $1
#        for (i=0;i<int($2);i++) printf "*"
#        printf "\n" }'
2       *
4       *
5       ***
6       *
7       **
8       *
10      ********
20      *********
30      ******
40      *****
50      **
60      **
70      **
80      **
90      *
100     ***
200     **
```

(With judicious function definitions, I got this down to
`wc -l $(ack -f --shell) | G -v 'total' | fields 1 | nearest_ten | frequency | histogram_f`
.)

To be clear, my argument is that emilper presents good reasons against Perl in
large systems. But not against Perl v. Bash.

> It baffles me the most because the common objection to Perl is legibility.
> Even if you assume that the objection is made from ignorance - i.e. not even
> having looked at some Perl to gauge its legibility - the nonsense you see in a
> complex bash script is orders of magnitude worse!
>
> Not to mention its total lack of common language features like first-class data
> and... Like, a compiler...
>
> I no longer write bash scripts because it takes about 5 lines to become
> unmaintainable.
>
> ---u/Altreus

Bad programmers do not a bad language make. We make fun of PHP's design
decisions, and say it's a bad language. Bash has its warts, like all languages,
but fundamentally it is well designed, and small. It's a shell: if it is terse,
it is for efficiency. The knowledgeable Bash programmer has a handful of trusty
concepts that he wields like knives, cutting programs this way and that until
they do what is required.

Bash can be readable. Isolate functions. Compose pipelines. Eliminate duplicate
code where reasonable. Use good names. `set -euo pipefail` so you don't shoot
yourself in the foot.

The language has idioms, like any other. Learn them. Bash is maintainable: just
look at my line counts above!

First-class data? Bash is too meta for that: it permits while read loops, but
most of the time another tool does that for you. Compose tools to act on data!

A compiler!? Forget not that Bash has it's origins as a *shell*---it is by
nature interactive and must be interpreted. You don't care that Perl is
interpreted… it's all just compiling on-the-fly.

Don't bash Bash because you have seen poor code.

> There's a long history of bad code written by mediocre developers who became
> the only one who could maintain the codebase until they no longer worked for
> the organization. The next poor sap to go in found a mess of a codebase and
> did their best to not break it further. After a few iterations, the whole
> thing is ready for /dev/null and Perl gets the blame […]
>
> ---u/codon011

See above: Bash suffers from the same appearance. **Bash is not scary.**

If you are a Bash programmer, for the love of God, don't make it scary. Do the
sane thing and write legible scripts. I don't care what you do interactively;
that can be gibberish. Scripts must be maintained.

And then there's this person, who gets it:

> To be fair, wrapping a Perl script around something that's (if I read your
> comment right) just running SCP is adding a pointless extra layer of
> complexity anyway.
>
> It's a matter of using the best tool for each particular job, not just sticking
> with one. My own ~/bin directory has a big mix of Perl and pure shell, depending
> on the complexity of the job to be done.
>
> ---u/beermad

*This* is why I don't reach for Perl. I don't need Perl to scp. I need `scp(1)`,
damnit.

I have written one real Perl thing ([Plink]({% link
_posts/2019-07-15-plink-release.md %})). It was just complex enough to be
interesting. But if I'm doing that frequency thing above? Bash, baby.

## Conclusion

Bash is all about composing tools. It can be bent into other things, but
ultimately it prefers to have a meta-language feel, composing other languages to
do what they do best.

Bash programmers are polyglots. We reach for a Perl or Python or Ruby one-liner
when necessary, but often accomplish the same in `awk(1)` or `grep(1)` or
`sed(1)`. I've even used `ed(1)` in a script before. Each of these tools has a
language that I learn and use. Others have flags and options---a unique
language.

The language of Bash is the language of its tools, with a few syntactic niceties
on top to make functions out of functions (`|`) and do simple control flow.

There's a reason almost every language provides a convenient way to "shell
out"---it's too powerful not to.
