---
title: Reading List
permalink: /reading/
---

> This is a list of blogs, websites, and other random junk that I have enjoyed
> reading or intend to eventually read. Where possible, I have attempted to
> respect the author's title of the site.
>
> This list is not ordered in any kind of way.
>
> The opinions contained in these sites do not necessarily reflect my own.

In addition to the entries below, check out my list of [subscribed RSS
feeds][feeds].

## Stuff I read regularly now

(Or: things I enjoy now as a curious, non-conforming luddite with strong
principles.)

<ul>
{% for blog in site.data.reading_list['new'] %}
  <li>
  <a href="{{blog.url}}">{{blog.title}}</a>
  </li>
{% endfor %}
</ul>

## Stuff I read or intended to read as a (naïve?) student with copious free time

(Or: what I think helped me gain knowledge as a student & junior engineer.)

<ul>
{% for blog in site.data.reading_list['old'] %}
  <li>
  <a href="{{blog.url}}">{{blog.title}}</a>
  </li>
{% endfor %}
</ul>

[feeds]: https://github.com/benknoble/Dotfiles/blob/master/links/newsboat/urls
