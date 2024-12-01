---
title: 'Scraping XML sitemaps with Racket'
tags: [racket]
category: [ Blog ]
---

Day 2 of "Advent of Racket"

## The project

Many of the smartest people I know keep an external cortex or exobrain: notes, a
[personal wiki](https://github.com/benknoble/wiki-md), or even a blog. Inspired
by [Cory Doctorow's "memex
method"](https://pluralistic.net/2021/05/09/the-memex-method/) and a
[RacketCon](https://con.racket-lang.org) question, I'm writing again when the
mood strikes---see the uptick in posts since the middle of this year.

The advantage of a memex or external digital cortex is several-fold. The act of
setting my thoughts out for an audience helps me to elucidate what otherwise
might be a 10-word bullet, filed away and forgotten about. For Cory Doctorow, it
keeps information connected in a tangled web that eventually crystallizes or
nucleates into a bigger form. ([Sound familiar? I've written about how my brain
often works that way, too.]({% link _writings/blankboards.md %}))

### Learning from the past to look towards the future

If you made it this far, you're probably wandering what this has to do with
scraping sitemaps… as Cory Doctorow writes, "systematically reviewing your older
work" is "hugely beneficial." Looking at the patterns (wrong and right) is a
"useful process of introspection" to improve our abilities to "spot and avoid"
pitfalls.

Doctorow revisits "this day in history" on the major anniversaries:

> For more than a decade, I’ve revisited “this day in history” from my own
> blogging archive, looking back one year, five years, ten years (and then,
> eventually, 15 years and 20 years). Every day, I roll back my blog archives to
> this day in years gone past, pull out the most interesting headlines and
> publish a quick blog post linking back to them.
>
> This structured, daily work of looking back on where I’ve been is more
> valuable to helping me think about where I’m going than I can say.

This review idea fascinated me. While I don't have the online tenure that
Doctorow does, I do have some old writing. So the idea to add a program to my
daily life to show me that writing was born.

The program should take a month and day (defaulting to the current) and show me
_every_ post that I've written on that day. URLs are sufficient; I can click
them or pipe them to `xargs -L1 open`. I don't need to worry about the year, at
least not yet. It would be an easy modification to add later though. Since I
publish an XML sitemap on my blog, we'll scrape that rather than the raw HTML.

## The code

The most up-to-date version of the script will always be in my [Dotfiles]({{
site.data.people.benknoble.dotfiles }}); [here's a permalink to the version at
time of
writing](https://github.com/benknoble/Dotfiles/blob/4f5f9cde16829914fff1ad43965f2e3e46e52c50/links/bin/blog-posts-on).

We start with a stanza to make this executable by the shell but written in
Racket (and we make sure to let Vim know what to do with it, since my
[filetype-detection
code](https://github.com/benknoble/vim-racket/blob/master/ftdetect/racket.vim)
for Racket [doesn't work with `#!` lines
yet](https://github.com/benknoble/vim-racket/issues/5)):

```racket
#! /usr/bin/env racket
#lang racket
; vim: ft=racket
```

Now we require a few libraries from the main distribution; that means this
program should work with most non-minimal Racket installations without depending
on other packages being installed:

```racket
(require xml
         xml/path
         net/http-client
         racket/date)
```

We need to know the month and day to use for our scraping; as mentioned, we'll
default to the current day but optionally parse values out of the command line:

```racket
(define now (current-date))

(define-values (month day)
  (command-line
   #:args ([month (~a (date-month now))] [day (~a (date-day now))])
   (unless (string->number month)
     (error "month should be numeric: " month))
   (unless (string->number day)
     (error "day should be numeric: " day))
   (values (~r (string->number month) #:min-width 2 #:pad-string "0")
           (~r (string->number day) #:min-width 2 #:pad-string "0"))))
```

The duplication is a bit bothersome, but in a ~40-line program I'm not
concerned for the moment. It _is_ important that we pad the dates to match my
site's URL format, which uses 2-digit months and days everywhere.

Next, we fire off a request to the sitemap. Notice the lack of error handling:
this doesn't need to be production grade, so we'll assume the request succeeds.

```racket
(define-values (_status _headers response)
  (http-sendrecv "benknoble.github.io" "/sitemap.xml" #:ssl? #t))
```

Now `response` is an [_input
port_](https://docs.racket-lang.org/reference/ports.html#%28tech._input._port%29):
we can read from it, but we haven't materialized a full (byte)string yet. We
know it contains an XML document, so let's read it as XML, extract the main
document, and turn that into an
[xexpr](https://docs.racket-lang.org/xml/index.html#%28def._%28%28lib._xml%2Fprivate%2Fxexpr-core..rkt%29._xexpr~3f%29%29):

```racket
(define doc
  (xml->xexpr (document-element (read-xml response))))
```

Almost done: we can query the document for the URLs (which happen to be `loc`
elements) and filter them by our month-day combo:

```racket
(define locations
  (se-path*/list '(loc) doc))

(define posts
  (filter-map
   (λ (loc)
     (regexp-match (pregexp (~a ".*" month "/" day ".*")) loc))
   locations))
```

Note how useful `filter-map` is with `regexp-match`: `filter-map` discards any
`#f` results from the mapping function, while `regexp-match` returns `#f` for
any inputs that don't match. Simultaneously it transforms matching inputs to
describe the matches.

Finally, we display all the (newline-separated) results! We use `first` to
extract the full original input string because the earlier `regexp-match`
produces `(list full-match sub-group ...)`; our `full-match` is the whole string
because we bracket `month/day` with `.*` patterns.

```racket
(for-each (compose1 displayln first) posts)
```

And that's a wrap!

### Use

In practice, I try to run `blog-posts-on` (the name of the script) once a day.
Sometimes I forget, so I build up a range of month/day combinations with
something like (Zsh):

```zsh
print -l -- 11\ {17..22} | xargs -L1 blog-posts-on
```

That gets me the posts for November 17th through 22nd, for example. If I want to
open them all immediately, I pipe that to `xargs -L1 open` as mentioned
(substitute `xdg-open` or equivalent on your operating system).

### Full code

```racket
#! /usr/bin/env racket
#lang racket
; vim: ft=racket

(require xml
         xml/path
         net/http-client
         racket/date)

(define now (current-date))

(define-values (month day)
  (command-line
   #:args ([month (~a (date-month now))] [day (~a (date-day now))])
   (unless (string->number month)
     (error "month should be numeric: " month))
   (unless (string->number day)
     (error "day should be numeric: " day))
   (values (~r (string->number month) #:min-width 2 #:pad-string "0")
           (~r (string->number day) #:min-width 2 #:pad-string "0"))))

(define-values (_status _headers response)
  (http-sendrecv "benknoble.github.io" "/sitemap.xml" #:ssl? #t))

(define doc
  (xml->xexpr (document-element (read-xml response))))

(define locations
  (se-path*/list '(loc) doc))

(define posts
  (filter-map
   (λ (loc)
     (regexp-match (pregexp (~a ".*" month "/" day ".*")) loc))
   locations))

(for-each (compose1 displayln first) posts)
```
