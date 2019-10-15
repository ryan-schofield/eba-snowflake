SELECT json_data['id']::INT AS flyby_id
	,json_data['name']::TEXT AS flyby_name
	,json_data['date']::DATE AS flyby_date
	,json_data['altitude']::FLOAT AS altitude
	,json_data['speed']::FLOAT AS speed
FROM {{ref('jpl_flybys')}}