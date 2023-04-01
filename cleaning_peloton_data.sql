-- create workouts table

CREATE TABLE public.fitness
(
    workout_timestamp timestamp with time zone,
    live character varying(50),
    instructor_name character varying(75),
    length integer,
    discipline character varying(75),
    type character varying(100),
    title character varying(100),
    class_timestamp timestamp with time zone,
    total_output integer,
    watts integer,
    resistance character varying(25),
    cadence integer,
    speed numeric,
    distance numeric,
    calories_burned integer,
    heartrate numeric,
    incline integer,
    pace integer
);

ALTER TABLE IF EXISTS public.fitness
    OWNER to postgres;

-- change resistance type from integer to varchar (because of percent) then upload .csv file with data

ALTER TABLE workouts
ALTER COLUMN resistance TYPE varchar(50);

-- add id number to each workout to set a primary key

ALTER TABLE workouts
ADD COLUMN id SERIAL PRIMARY KEY;

-- drop column live (I only ever do on demand workouts)

ALTER TABLE workouts
DROP COLUMN live;

-- count total instructors tried on the platform
-- currently only 51 instructors work at peloton and I know there are more than 2 I have not tried

SELECT COUNT(DISTINCT instructor_name)
FROM workouts;

-- found problem, some classes with multiple instructors list ‘_ &_’ instead of ‘Multiple Instructors’

SELECT instructor_name
FROM workouts
GROUP BY instructor_name
ORDER BY instructor_name;

-- check for multiple instructors listed with ‘&’

SELECT *
FROM workouts
WHERE instructor_name iLIKE '%&%';

-- change workouts with multiple instructors to multiple instructors

UPDATE workouts
SET instructor_name = REPLACE(instructor_name, 'Cody & Emma', 'Multiple Instructors');

UPDATE workouts
SET instructor_name = REPLACE(instructor_name, 'Ally & Emma', 'Multiple Instructors');

UPDATE workouts
SET instructor_name = REPLACE(instructor_name, 'Matty & Olivia', 'Multiple Instructors');

UPDATE workouts
SET instructor_name = REPLACE(instructor_name, 'Cody & Leanne', 'Multiple Instructors');

-- why is this only returning two results

SELECT *
FROM workouts
WHERE instructor_name = 'Multiple Instructors';

-- this returns all of them

SELECT *
FROM workouts
WHERE instructor_name iLIKE '%multiple%';

-- there must be whitespace because multiple instructors is showing as two different instructors

SELECT LENGTH(instructor_name),
	instructor_name
FROM workouts
GROUP BY instructor_name
ORDER BY instructor_name;

-- trim whitespace

UPDATE workouts
SET instructor_name = TRIM (instructor_name);

-- check min and max of length of workout, calories burned, output, and watts to check for outliers

SELECT MIN(length) AS min_length,
	MAX(length) AS max_length
FROM workouts;

SELECT MIN(calories_burned) AS min_cal,
	MAX(calories_burned) AS max_cal
FROM workouts;

SELECT MIN(total_output) AS min_output,
	MAX(total_output) AS max_output
FROM workouts;

SELECT MIN(watts) AS min_watts,
	MAX(watts) AS max_watts
FROM workouts;

-- extract dow from timestamp

SELECT workout_timestamp,
	EXTRACT (DOW from workout_timestamp) AS dow
FROM workouts;

-- add dow column to table

ALTER TABLE workouts
ADD COLUMN day_of_week integer;

-- add data to dow column

UPDATE workouts
	SET day_of_week = EXTRACT (DOW from workout_timestamp);

-- change day_of_week data type from integer to string

ALTER TABLE workouts
ALTER COLUMN day_of_week TYPE varchar(25);

-- change numbers to day of week

UPDATE workouts
SET day_of_week =
	CASE day_of_week
		WHEN '0' THEN 'Sunday'
		WHEN '1' THEN 'Monday'
		WHEN '2' THEN 'Tuesday'
		WHEN '3' THEN 'Wednesday'
		WHEN '4' THEN 'Thursday'
		WHEN '5' THEN 'Friday'
		WHEN '6' THEN 'Saturday'
	END;

-- add column for time of day workout was done

ALTER TABLE workouts
ADD COLUMN time_of_day_of_workout time;

-- extract hour and minutes of workout timestamp and store in new column

UPDATE workouts
SET time_of_day_of_workout = CAST((EXTRACT(HOUR FROM workout_timestamp)||':'||EXTRACT(MINUTE FROM workout_timestamp)) AS TIME);

-- look at all different workout disciplines

SELECT discipline
FROM workouts
GROUP BY discipline
ORDER BY discipline;

-- add new column to indicate training type and sort workout into broader discipline categories

ALTER TABLE workouts
ADD COLUMN training_type varchar(50);

UPDATE workouts SET training_type =
    CASE discipline
        WHEN 'Bike Bootcamp' THEN 'cardio'
        WHEN 'Cardio' THEN 'cardio'
        WHEN 'Cycling' THEN 'cardio'
		WHEN 'Meditation' THEN 'recovery'
		WHEN 'Running' THEN 'cardio'
		WHEN 'Strength' THEN 'strength'
		WHEN 'Stretching' THEN 'recovery'
		WHEN 'Walking' THEN 'cardio'
		WHEN 'Yoga' THEN 'strength'
	END;

-- create column and add data to sort by training type and length to determine how active day is

ALTER TABLE workouts
ADD COLUMN daily_intensity varchar(50);

UPDATE workouts SET daily_intensity =
	   CASE
           WHEN length < 20
                AND training_type = 'strength' THEN 'light'
           WHEN length >= 20
                AND training_type = 'strength' THEN 'active'
           WHEN length < 20
                AND training_type = 'cardio' THEN 'light'
			WHEN length >= 20
                AND training_type = 'cardio' THEN 'active'
       ELSE 'recovery'
	   END;

-- confirm only 3 intensity types of new column created

SELECT COUNT (DISTINCT daily_intensity)
FROM workouts;

-- remove % from resistance column

UPDATE workouts
SET resistance =
	TRIM(TRAILING '%' FROM resistance);

-- convert resistance column from string (character varying) to numeric

ALTER TABLE workouts
ALTER COLUMN resistance TYPE numeric
USING resistance::numeric;
