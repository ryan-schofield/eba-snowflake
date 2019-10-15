{{ config(materialized='ephemeral') }}

SELECT {{nasa_date('sclk')}} AS sclk
    ,alt_t
    ,{{nasa_date('sclk')}}::DATE AS sclk_date
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