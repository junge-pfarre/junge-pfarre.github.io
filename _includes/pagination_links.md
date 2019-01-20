<div class="pagination">
  {% if paginator.previous_page %}
    <a href="{{ paginator.previous_page_path }}" class="previous">
      Neuer
    </a>
     |
  {% endif %}
  <span class="page_number ">
    Seite {{ paginator.page }} von {{ paginator.total_pages }}
  </span>
  {% if paginator.next_page %}
     |
    <a href="{{ paginator.next_page_path }}" class="next">Älter</a>
  {% endif %}
</div>
