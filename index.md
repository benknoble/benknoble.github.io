---
layout: default
title: Home
---

    "Do you keep your junk drawer full of fun and creative things?"

## Latest Post
{% assign latest = site.posts.first %}
[{{ latest.title }}]({{ latest.url }}) posted on {{ latest.date | date: "%d %B %Y" }}

Excerpt:

> {{ latest.excerpt | remove: '<p>' | remove: '</p>' }}

## Recent Posts
{% for post in site.posts offset:1 limit:2 %}
- [{{ post.title }}]({{ post.url }}) posted on {{ post.date | date: "%d %B %Y" }}
{% endfor %}
