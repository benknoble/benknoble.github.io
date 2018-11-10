---
title: Reading List
permalink: /reading/
---

{% for blog in site.data.reading_list %}
- [{{blog.title}}]({{blog.url}})
{% endfor %}
