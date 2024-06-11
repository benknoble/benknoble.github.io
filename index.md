---
title: Home
---

_Do you keep your junk drawer full of fun and creative things?_

On this site, [I break down complex answers to simple questions]({% link
pages/about.md %}#me).

## Latest Post
{% assign latest = site.posts.first %}
[{{ latest.title }}]({{ latest.url }}) posted on {{ latest.date | date: "%d %B %Y" }}

Excerpt:

> {{ latest.excerpt | remove: '<p>' | remove: '</p>' }}

## Recent Posts
<ul>
{% for post in site.posts offset:1 limit:2 %}
  <li>
  <a href="{{ post.url }}">{{ post.title }}</a> posted on {{ post.date | date: "%d %B %Y" }}
  </li>
{% endfor %}
</ul>
