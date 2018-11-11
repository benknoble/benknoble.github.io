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

{% for blog in site.data.reading_list %}
- [{{blog.title}}]({{blog.url}})
{% endfor %}
