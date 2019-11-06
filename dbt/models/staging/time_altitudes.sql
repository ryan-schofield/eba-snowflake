SELECT {{nasa_date('sclk')}} AS time_stamp
    ,alt_t::NUMBER(9, 2) AS altitude
    ,date_part(YEAR, {{nasa_date('sclk')}}) AS year
    ,date_part(WEEK, {{nasa_date('sclk')}}) AS week
FROM {{source('raw','inms')}} x
WHERE alt_t IS NOT NULL
    AND UPPER(target) = 'ENCELADUS'
    