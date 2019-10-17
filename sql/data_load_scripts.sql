-- create warehouse
CREATE WAREHOUSE ZERO_TO_SF_WH WITH 
	WAREHOUSE_SIZE = 'XSMALL' 
	WAREHOUSE_TYPE = 'STANDARD' 
	AUTO_SUSPEND = 60 
	AUTO_RESUME = TRUE 
	MIN_CLUSTER_COUNT = 1 
	MAX_CLUSTER_COUNT = 1 
	SCALING_POLICY = 'STANDARD';

-- switch to warehouse
USE WAREHOUSE ZERO_TO_SF_WH;

-- create database
CREATE DATABASE ZERO_TO_SF;

-- switch to database
USE DATABASE ZERO_TO_SF;

-- create schema
CREATE SCHEMA ZERO_TO_SF.RAW;

-- switch to schema
USE SCHEMA ZERO_TO_SF.RAW;

-- grant permissions
GRANT ALL ON SCHEMA RAW TO SYSADMIN;
GRANT ALL ON SCHEMA RAW TO ACCOUNTADMIN;
GRANT ALL ON ALL TABLES IN SCHEMA ZERO_TO_SF.RAW TO ROLE SYSADMIN;
GRANT ALL ON ALL TABLES IN SCHEMA ZERO_TO_SF.RAW TO ROLE ACCOUNTADMIN;
GRANT ALL ON FUTURE TABLES IN SCHEMA ZERO_TO_SF.RAW TO ROLE SYSADMIN;
GRANT ALL ON FUTURE TABLES IN SCHEMA ZERO_TO_SF.RAW TO ROLE SYSADMIN;

-- create table for jpl_flybys.json
CREATE OR REPLACE TABLE JPL_FLYBYS (
	JSON_DATA VARIANT
);

-- show create table sql
SELECT GET_DDL( 'TABLE' , 'RAW.JPL_FLYBYS'); 

-- add file format for jpl_flybys.json
CREATE FILE FORMAT ZERO_TO_SF.RAW.JSON_ARRAY 
	TYPE = 'JSON' 
	COMPRESSION = 'AUTO' 
	ENABLE_OCTAL = FALSE 
	ALLOW_DUPLICATE = FALSE 
	STRIP_OUTER_ARRAY = TRUE 
	STRIP_NULL_VALUES = FALSE 
	IGNORE_UTF8_ERRORS = FALSE 
	COMMENT = 'ROW PER DOCUMENT FROM JSON ARRAY';

-- upload and copy jpl_flybys.json
PUT file://<file_path>/jpl_flybys.json @JPL_FLYBYS/<upload_location>;

COPY INTO ZERO_TO_SF.RAW.JPL_FLYBYS 
	FROM @/<upload_location> 
	FILE_FORMAT = 'ZERO_TO_SF.RAW.JSON_ARRAY' 
	ON_ERROR = 'ABORT_STATEMENT' 
	PURGE = TRUE;

-- show loaded data with variant column
SELECT *
FROM RAW.JPL_FLYBYS;

-- select from json
SELECT JSON_DATA ['date']
FROM RAW.JPL_FLYBYS;

-- select from json and cast types
SELECT json_data['id']::INT AS flyby_id
	,json_data['name']::TEXT AS flyby_name
	,json_data['date']::DATE AS flyby_date
	,json_data['altitude']::FLOAT AS altitude
	,json_data['speed']::FLOAT AS speed
FROM RAW.JPL_FLYBYS;

-- create file format for master_plan.txt (pipe delimited, quote text, '\' escape, mixed types with json)
CREATE OR REPLACE FILE FORMAT MASTER_PLAN_FORMAT
	FIELD_DELIMITER = '|'
	SKIP_HEADER = 1
	ESCAPE = '\\'
	FIELD_OPTIONALLY_ENCLOSED_BY = '\"'
	NULL_IF = ('');

-- create stage for s3 files
CREATE OR REPLACE STAGE ENCELADUS_DATA URL='s3://eide-bailly-zero-to-snowflake-demo/'
    -- CREDENTIALS = ( AWS_KEY_ID = 'XXXXXXXXXXXXXXXXXXXX' AWS_SECRET_KEY = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
    -- FILE_FORMAT = (FORMAT_NAME = 'MASTER_PLAN_FORMAT');

-- create table for master_plan.txt (pipe delimited, quote text, mixed types with json)
CREATE OR REPLACE TABLE RAW.MASTER_PLAN (
	START_TIME_UTC VARCHAR(16777216),
	DURATION VARCHAR(16777216),
	DATE VARCHAR(16777216),
	JSON_DATA VARIANT
);

-- -- copy master_plan.txt from stage
-- COPY INTO RAW.MASTER_PLAN
--     FROM @ENCELADUS_DATA/master_plan.txt
--     FILE_FORMAT = (FORMAT_NAME = 'MASTER_PLAN_FORMAT');

-- copy master_plan.txt directly from s3
COPY INTO RAW.MASTER_PLAN
    FROM s3://eide-bailly-zero-to-snowflake-demo/master_plan.txt
    FILE_FORMAT = (FORMAT_NAME = 'MASTER_PLAN_FORMAT');

-- create table for inms.csv.gz (comprressed csv)
CREATE OR REPLACE TABLE RAW.INMS (
	sclk TEXT
	,target TEXT
	,source TEXT
	,mass_table TEXT
	,mass_per_charge TEXT
	,p_energy TEXT
	,alt_t TEXT
	,sc_vel_t_scx TEXT
	,sc_vel_t_scy TEXT
	,sc_vel_t_scz TEXT
	,c1counts TEXT
	,c2counts TEXT
	);

-- copy inms.csv.gz 
COPY INTO RAW.INMS
    FROM s3://eide-bailly-zero-to-snowflake-demo/inms.csv.gz
    FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1);

-- create table for cda.csv    
CREATE OR REPLACE TABLE RAW.CDA (
	EVENT_ID TEXT
	,EVENT_TIME TEXT
	,EVENT_JULIAN_DATE TEXT
	,QP_AMPLITUDE TEXT
	,QI_AMPLITUDE TEXT
	,QT_AMPLITUDE TEXT
	,QC_AMPLITUDE TEXT
	,SPACECRAFT_SUN_DISTANCE TEXT
	,SPACECRAFT_SATURN_DISTANCE TEXT
	,SPACECRAFT_X_VELOCITY TEXT
	,SPACECRAFT_Y_VELOCITY TEXT
	,SPACECRAFT_Z_VELOCITY TEXT
	,COUNTER_NUMBER TEXT
	,PARTICLE_MASS TEXT
	,PARTICLE_CHARGE TEXT
	);

-- copy cda.csv
COPY INTO RAW.CDA
    FROM s3://eide-bailly-zero-to-snowflake-demo/cda.csv
    FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1);

-- add staging schema
CREATE SCHEMA IF NOT EXISTS DW_STAGING;

-- create table with typed columns from jpl_flyby data
CREATE OR REPLACE TABLE DW_STAGING.JPL_FLYBY AS
  SELECT json_data['id']::INT AS flyby_id
      ,json_data['name']::TEXT AS flyby_name
      ,json_data['date']::DATE AS flyby_date
      ,json_data['altitude']::FLOAT AS altitude
      ,json_data['speed']::FLOAT AS speed
  FROM RAW.JPL_FLYBYS;

-- table cloning and time travel
CREATE TABLE RAW.CHEM_DATA_CLONE CLONE RAW.CHEM_DATA --AT (TIMESTAMP => to_timestamp_tz('04/05/2013 01:02:03', 'mm/dd/yyyy hh24:mi:ss'));
