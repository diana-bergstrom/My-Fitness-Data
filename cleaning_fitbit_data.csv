-- create table in fitness database for weight then upload data from .csv file

CREATE TABLE public.weight
(
  date date,
  weight numeric,
  "BMI" numeric
);

ALTER TABLE IF EXISTS public.weight
    OWNER to postgres;

-- create table in fitness database for activity then upload data from .csv file

CREATE TABLE public.activity
(
    date date,
    calories_in integer,
    calories_burned integer,
    steps integer,
    distance numeric,
    floors smallint,
    sedentary_min integer,
    lightly_active_min integer,
    fairly_active_min integer,
    very_active_min integer,
    active_calories integer
);

ALTER TABLE IF EXISTS public.activity
    OWNER to postgres;

-- add unique id as primary key in each table

ALTER TABLE weight
ADD COLUMN id SERIAL PRIMARY KEY;

ALTER TABLE activity
ADD COLUMN id SERIAL PRIMARY KEY;

-- check min and max of weight and bmi in weight table to confirm no outliers

SELECT
	MIN(weight) AS min_weight,
	MAX(weight) AS max_weight,
	MIN(bmi) AS min_bmi,
	MAX(bmi) AS max_bmi
FROM weight;

-- check min and max of columns in activity table to confirm no outliers

SELECT
	MIN(calories_in) AS min_cal_in,
	MAX(calories_in) AS max_cal_in,
	MIN(calories_burned) AS min_cal_burned,
	MAX(calories_burned) AS max_cal_burned,
	MIN(steps) AS min_steps,
	MAX(steps) AS max_steps,
	MIN(distance) AS min_distance,
	MAX(distance) AS max_distance,
	MIN(floors) AS min_floors,
	MAX(floors) AS max_floors,
	MIN(sedentary_min) AS min_sed,
	MAX(sedentary_min) AS max_sed,
	MIN(lightly_active_min) AS min_light,
	MAX(lightly_active_min) AS max_light,
	MIN(fairly_active_min) AS min_fair,
	MAX(fairly_active_min) AS max_fair,
	MIN(very_active_min) AS min_very,
	MAX(very_active_min) AS max_very,
	MIN(active_calories) AS min_active_cal,
	MAX(active_calories) AS max_active_cal
FROM activity;

-- there should be 365 unique date entries

SELECT COUNT (DISTINCT date)
FROM weight;

SELECT COUNT (DISTINCT date)
FROM activity;

-- look at avg values in activity table to help determine how we want to classify active days

SELECT
	ROUND(AVG(calories_burned), 0) AS avg_cal,
	ROUND(AVG(floors), 0) AS floors,
	ROUND(AVG(sedentary_min), 0) AS sedentary,
	ROUND(AVG(lightly_active_min), 0) AS lightly_active,
	ROUND(AVG(fairly_active_min), 0) AS fairly_active,
	ROUND(AVG(very_active_min), 0) AS very_active,
	ROUND(AVG(active_calories), 0) AS active_cal
FROM activity;

-- can also check median value for floors

SELECT
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY floors) AS median_floors
FROM activity;

-- many dates have entry for floors as 0 and looking further it is because I switched fitbit trackers on 04-22-2020 and the new tracker did not track floors/elevation

SELECT *
FROM activity
WHERE floors = 0
ORDER BY date;

-- change floor column type to string so that null can be entered to reflect no floors logged after 2020-04-22

ALTER TABLE activity
ALTER COLUMN floors TYPE varchar(25);

UPDATE activity
SET floors = 'null'
WHERE floors = '0'
AND date >= '2020-04-22';


-- drop calories_in column since logs were minimally completed

ALTER TABLE activity
DROP COLUMN calories_in

-- delete entries where steps = 0 or < 1800 calories burned which reflect days that tracker was worn minimally

DELETE FROM activity
WHERE steps = 0;

DELETE FROM activity
WHERE calories_burned < 1800;

-- add column to classify daily activity

ALTER TABLE activity
ADD COLUMN activity_level varchar(50);

-- an average 25 year old burns about 2,802 daily calories with moderate activity level

UPDATE activity
SET activity_level = 'less active'
WHERE calories_burned < 2802;

UPDATE activity
SET activity_level = 'more active'
WHERE calories_burned > 2802;
