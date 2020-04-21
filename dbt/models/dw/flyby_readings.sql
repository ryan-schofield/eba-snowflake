SELECT fb.flyby_id
	,fb.flyby_name
	,cd.name AS chem_name
	,cd.formula AS chem_formula
	,inms.source
	,CASE 
		WHEN cd.formula IN ('H2', 'CH4', 'CO2', 'H2O')
			THEN TRUE
		ELSE FALSE
		END AS is_thumbprint_of_life
	,sum(inms.high_counts) AS high_counts
	,sum(inms.low_counts) AS low_counts
FROM {{ref('flybys')}} fb
INNER JOIN {{ref('inms_readings')}} inms
	ON inms.time_stamp >= fb.window_start
		AND inms.time_stamp <= fb.window_end
INNER JOIN {{source('datalake','chem_data')}} cd
	ON cd.peak = inms.mass_per_charge
WHERE fb.targeted = TRUE
GROUP BY fb.flyby_id
	,fb.flyby_name
	,cd.name
	,cd.formula
	,inms.source
