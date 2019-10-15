-- get the min flyby altitude for the 23 passes of Enceladus

-- preview rows in table. note year, day of year format 
SELECT *
FROM RAW.INMS LIMIT 10;

-- split values from timestamp string.
SELECT SPLIT(REPLACE(SCLK, 'T', '-'), '-') AS SPLIT_VALS
FROM RAW.INMS LIMIT 10;

-- select individual values from the array
SELECT SPLIT(REPLACE(SCLK, 'T', '-'), '-') [0]::INT AS REC_YEAR
    ,SPLIT(REPLACE(SCLK, 'T', '-'), '-') [1]::INT AS REC_DAY
    ,SPLIT(REPLACE(SCLK, 'T', '-'), '-') [2]::TIME AS REC_TIME
FROM RAW.INMS LIMIT 10;

-- convert string values to date with DATE_FROM_PARTS and convert to timestamp
SELECT (
    DATE_FROM_PARTS(
        SPLIT(REPLACE(SCLK, 'T', '-'), '-') [0]::INT, 1
        ,SPLIT(REPLACE(SCLK, 'T', '-'), '-') [1]::INT
        )::STRING 
    || ' ' 
    || SPLIT(REPLACE(SCLK, 'T', '-'), '-') [2]::STRING
    )::DATETIME
FROM RAW.INMS LIMIT 10;

-- add a scalar UDF for the timestamp conversion
CREATE OR REPLACE FUNCTION NASA_DATE (NASA_STR STRING)
RETURNS DATETIME 
AS 
$$
    (
        DATE_FROM_PARTS(
            SPLIT(REPLACE(NASA_STR, 'T', '-'), '-') [0]::INT, 1
            ,SPLIT(REPLACE(NASA_STR, 'T', '-'), '-') [1]::INT
            )::STRING 
        || ' ' 
        || SPLIT(REPLACE(NASA_STR, 'T', '-'), '-') [2]::STRING
    )::DATETIME
$$;

-- test the UDF
SELECT NASA_DATE(SCLK) AS NASA_DATE
FROM RAW.INMS LIMIT 10;

-- create a table with altitudes for the Enceladus flybys
CREATE OR REPLACE TRANSIENT TABLE DW_STAGING.FLYBY_ALTITUDES AS 
    SELECT NASA_DATE(SCLK) AS FLYBY_DATE
        ,ALT_T::NUMBER(10, 3) AS ALTITUDE
    FROM RAW.INMS
    WHERE TARGET = 'ENCELADUS'
        AND ALT_T IS NOT NULL;


-- get the nadir for each date
SELECT FLYBY_DATE::DATE AS FLYBY_DATE
    ,MIN(ALTITUDE) AS DAILY_MIN
FROM DW_STAGING.FLYBY_ALTITUDES
GROUP BY FLYBY_DATE::DATE
ORDER BY MIN(ALTITUDE);

-- group by year and week to get the min value for each of the 23 flybys 
SELECT DATE_PART(YEAR, FLYBY_DATE) AS FLYBY_YEAR
    ,DATE_PART(WEEK, FLYBY_DATE) AS FLYBY_WEEK
    ,MIN(ALTITUDE) AS FLYBY_MIN
FROM DW_STAGING.FLYBY_ALTITUDES
GROUP BY 1
    ,2
ORDER BY 1
    ,2;
