{{ 
	config(
	pre_hook = 'CREATE OR REPLACE SEQUENCE inms_readings_seq'
    )
}}

SELECT inms_readings_seq.nextval AS id
    ,{{nasa_date('sclk')}} AS time_stamp
    ,source
    ,mass_table
    ,alt_t::NUMBER(9, 2) AS altitude
    ,mass_per_charge::NUMBER(6, 3) AS mass_per_charge
    ,p_energy::NUMBER(7, 3) AS p_energy
    ,{{pythag('sc_vel_t_scx::NUMERIC', 'sc_vel_t_scy::NUMERIC', 'sc_vel_t_scz::NUMERIC')}} AS relative_speed
    ,c1counts::INTEGER AS high_counts
    ,c2counts::INTEGER AS low_counts
FROM {{source('datalake','inms')}}
ORDER BY time_stamp
