{% macro pythag(x, y, z) %}

SQRT(({{x}} * {{x}}) + ({{y}} * {{y}}) + ({{z}} * {{z}}))::NUMBER(10, 2)

{% endmacro %}


{% macro nasa_date(nasa_str) %}

    (
        DATE_FROM_PARTS(
            SPLIT(REPLACE({{nasa_str}}, 'T', '-'), '-') [0]::INT, 1
            ,SPLIT(REPLACE({{nasa_str}}, 'T', '-'), '-') [1]::INT
            )::STRING 
        || ' ' 
        || SPLIT(REPLACE({{nasa_str}}, 'T', '-'), '-') [2]::STRING
    )::DATETIME

{% endmacro %}