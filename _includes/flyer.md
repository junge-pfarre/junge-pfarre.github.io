{% assign flyers = site.static_files | where: "flyer", true %}
{% for flyer in flyers %}
  ![]({{ site.baseurl }}{{ flyer.path }})
{% endfor %}
