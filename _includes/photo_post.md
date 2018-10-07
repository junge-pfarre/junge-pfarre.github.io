{{ page.description }}

{% assign photos = site.static_files | where_exp:"file", "file.basename contains page.photo_filter" %}
{% for photo in photos %}
  ![{{ page.photos[forloop.index0].alt_text }}]({{ site.baseurl }}{{ photo.path }})
  {% if page.photos[forloop.index0].title %}_{{page.photos[forloop.index0].title }}_{% endif %}
{% endfor %}
