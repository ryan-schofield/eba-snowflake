{% macro pythag(x, y, z) %}

SQRT(({{x}} * {{x}}) + ({{y}} * {{y}}) + ({{z}} * {{z}}))::NUMBER(10, 2)

{% endmacro %}