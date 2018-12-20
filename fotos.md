---
---
# Fotos
<!-- Nimm alle Posts im Ordner "_posts" und füge sie mit Titel und Inhalt hier ein. -->
{% for post in site.posts %}
  <h2><span class="photo-date">{{ post.date | date: "%e.%m.%Y" }}</span>{{ post.title }}</h2>
  {{ post.content }}
{% endfor %}
