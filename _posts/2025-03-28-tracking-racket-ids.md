---
title: A tip on tracking down bound identifiers in Racket
tags: [ racket ]
category: [ Blog ]
---

Straight from the horse's mouth.

Or in this case, from Racket wizard Matthew Flatt.

> DrRacket can usually open the defining file via a right-click on an name. If
> not, or in more restrcted environments, I sometimes use `(identifier-binding
> #'name)` to help track down `name`, since the binding can identify the source
> module. If I didn't know where that module resides, I might try
> `(module-path-index-resolve (car (identifier-binding #'name)))`.
