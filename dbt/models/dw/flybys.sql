SELECT f.flyby_id
	,f.flyby_name
	,f.flyby_date
	,f.altitude
	,f.speed
	,mt.nadir
	,mt.year
	,mt.week
	,mt.low_time
	,mt.window_start
	,mt.window_end
	,CASE 
		WHEN f.flyby_id IN (3, 5, 7, 17, 18, 21)
			THEN true
		ELSE false
		END AS targeted
FROM {{ref('flyby_cols')}} f
INNER JOIN {{ref('min_times')}} mt
	ON date_part(YEAR, f.flyby_date) = mt.year
		AND date_part(WEEK, f.flyby_date) = mt.week
