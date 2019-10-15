SELECT min(altitude) AS nadir
	,year
	,week
FROM {{ref('time_altitudes')}}
GROUP BY year
	,week
ORDER BY year
	,week