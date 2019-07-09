---
title: 'Managing dotfiles--a DSL'
tags: [ tags ]
category: [ Blog, Code ]
---

#! /usr/bin/env interpreter

file => link
name ! command
name !!
commands
commands
!!

DSL -> make -f - {target}

cached makefile to avoid string manip every time?
