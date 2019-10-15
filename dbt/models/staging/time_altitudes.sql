SELECT sclk AS time_stamp
    ,alt_t::NUMBER(9, 2) AS altitude
    ,date_part(YEAR, sclk) AS year
    ,date_part(WEEK, sclk) AS week
FROM {{ref('inms')}} x
WHERE alt_t IS NOT NULL
    AND UPPER(target) = 'ENCELADUS'