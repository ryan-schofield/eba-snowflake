{{ config(materialized='ephemeral') }}

SELECT CAST(DATEADD(DAY, RIGHT(LEFT(sclk, 8),3)::INTEGER, CAST(LEFT(sclk, 4)||'-01-01' AS TIMESTAMP))::DATE::TEXT||'T'||RIGHT(sclk, 12) AS TIMESTAMP) AS sclk
    ,alt_t
    ,DATEADD(DAY, RIGHT(LEFT(sclk, 8),3)::INTEGER, CAST(LEFT(sclk, 4)||'-01-01' AS TIMESTAMP))::DATE AS sclk_date
    ,target
    ,source
    ,mass_table
    ,mass_per_charge
    ,p_energy
    ,sc_vel_t_scx
    ,sc_vel_t_scy
    ,sc_vel_t_scz
    ,c1counts
    ,c2counts
FROM raw.inms