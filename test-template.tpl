#!./template.bash

<html>
  <head>
    <title>Listing {% ls | wc -l %} files</title>
  </head>
  <body>
    <li>
      {% for i in *; do %}
      <p>{{$i}}</p>
      {% done %}
    </li>
  </body>
</html>

