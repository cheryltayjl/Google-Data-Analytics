-- combined Jan2023 to Dec2023 data
CREATE TABLE combinedtable AS SELECT * FROM (SELECT * FROM Jan2023 
			UNION ALL
			SELECT * FROM Feb2023
			UNION ALL
			SELECT * FROM Mar2023
			UNION ALL
			SELECT * FROM Apr2023
			UNION ALL
			SELECT * FROM May2023
			UNION ALL 
			SELECT * FROM Jun2023
			UNION ALL
			SELECT * FROM Jul2023
			UNION ALL
			SELECT * FROM Aug2023
			UNION ALL
			SELECT * FROM Sep2023
			UNION ALL
			SELECT * FROM Oct2023
			UNION ALL
			SELECT * FROM Nov2023
			UNION ALL
			SELECT * FROM Dec2023)
	
-- check the data		
SELECT * FROM combinedtable

-- Clean data
-- check total rows (5719877)
SELECT COUNT (*)
FROM combinedtable

-- check duplicates (5719877) means no duplicate ride_id
SELECT COUNT(DISTINCT (ride_id))
FROM combinedtable

-- checked for Null values in started_at and ended_at. No null values found.
SELECT ended_at, started_at
FROM combinedtable
WHERE ended_at is NULL or started_at is NULL

-- deleted the NULL values from start and end station name
DELETE FROM combinedtable
WHERE start_station_name IS NULL OR end_station_name IS NULL

-- noted that start_station_id and end_station_id have NULL values so deleted them as well
DELETE FROM combinedtable
WHERE end_station_id IS NULL or start_station_id is NULL

-- deleted the NULL values from latitude and longitude of the end station
DELETE FROM combinedtable
WHERE end_lng is NULL or end_lat is NULL

-- creating day_of_week and month columns
ALTER TABLE combinedtable ADD day_of_week TEXT
ALTER TABLE combinedtable ADD month TEXT

UPDATE combinedtable
SET day_of_week = CASE
	WHEN strftime ('%w', started_at) = '0' THEN 'SUN'
    WHEN strftime ('%w', started_at) = '1' THEN 'MON'
    WHEN strftime ('%w', started_at) = '2' THEN 'TUE'
    WHEN strftime ('%w', started_at) = '3' THEN 'WED'
    WHEN strftime ('%w', started_at) = '4' THEN 'THU'
    WHEN strftime ('%w', started_at) = '5' THEN 'FRI'
	ELSE 'SAT'
  END,
  month = CASE 
	WHEN strftime ('%m', started_at) = '01' THEN 'JAN'
	WHEN strftime ('%m', started_at) = '02' THEN 'FEB'
	WHEN strftime ('%m', started_at) = '03' THEN 'MAR'
	WHEN strftime ('%m', started_at) = '04' THEN 'APR'
	WHEN strftime ('%m', started_at) = '05' THEN 'MAY'
	WHEN strftime ('%m', started_at) = '06' THEN 'JUN'
	WHEN strftime ('%m', started_at) = '07' THEN 'JUL'
	WHEN strftime ('%m', started_at) = '08' THEN 'AUG'
	WHEN strftime ('%m', started_at) = '09' THEN 'SEP'
	WHEN strftime ('%m', started_at) = '10' THEN 'OCT'
	WHEN strftime ('%m', started_at) = '11' THEN 'NOV'
	WHEN strftime ('%m', started_at) = '12' THEN 'DEC'
    END

-- creating a ride length column in minutes
ALTER TABLE combined_table ADD ride_length_minutes INTEGER

UPDATE combinedtable
SET ride_length_minutes = (julianday(ended_at) - julianday(started_at)) * 1440

-- deleting rows less than 1 & greater than 1440
DELETE FROM combinedtable
WHERE ride_length_minutes <1 OR ride_length_minutes > 1440 

-- Analyze
-- number of riders who are casual or member
SELECT COUNT(ride_id) AS number_of_riders, member_casual
FROM combinedtable
GROUP BY member_casual
ORDER BY COUNT(ride_id) DESC

-- type of bikes used by members and casual riders
SELECT COUNT(ride_id) AS number_of_riders, rideable_type AS types_of_bikes, member_casual
FROM combinedtable
GROUP BY types_of_bikes, member_casual
ORDER BY number_of_riders DESC

-- average trip duration in a week
SELECT ROUND(AVG(ride_length_minutes),1) as average_trip_duration_minutes, day_of_week, member_casual
FROM combinedtable
GROUP BY day_of_week, member_casual

-- average trip duration by month
SELECT ROUND(AVG(ride_length_minutes),1) as average_trip_duration_minutes, month, member_casual
FROM combinedtable
GROUP BY month, member_casual

-- Top 10 start station name by casual riders
SELECT start_station_name, member_casual, count(*) AS number_of_rides
FROM combinedtable
WHERE member_casual = "casual"
GROUP BY start_station_name
ORDER BY number_of_rides DESC
LIMIT 10

-- Top 10 start station name by member riders
SELECT start_station_name, member_casual, count(*) AS number_of_rides
FROM combinedtable
WHERE member_casual = "member"
GROUP BY start_station_name
ORDER BY number_of_rides DESC
LIMIT 10
 
-- Top 10 end station name by casual riders
SELECT end_station_name, member_casual, count(*) AS number_of_rides
FROM combinedtable
WHERE member_casual = "casual"
GROUP BY end_station_name
ORDER BY number_of_rides DESC
LIMIT 10

-- Top 10 end station name by member riders
SELECT end_station_name, member_casual, count(*) AS number_of_rides
FROM combinedtable
WHERE member_casual = "member"
GROUP BY end_station_name
ORDER BY number_of_rides DESC
LIMIT 10