SELECT mins.*
    ,MIN(time_stamp) AS low_time
    ,DATEADD(SECOND, 20, MIN(time_stamp)) AS window_end
    ,DATEADD(SECOND, -20, MIN(time_stamp)) AS window_start
FROM {{ref('mins')}}
INNER JOIN {{ref('time_altitudes')}} ta
    ON mins.year = ta.year
        AND mins.week = ta.week
        AND mins.nadir = ta.altitude
GROUP BY mins.week
    ,mins.year
    ,mins.nadir