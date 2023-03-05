--union to bring together data from bluebikes_2016 to 2019

SELECT *
FROM bluebikes_2016
UNION
SELECT *
FROM bluebikes_2017
UNION
SELECT * 
FROM bluebikes_2018
UNION
SELECT *
FROM bluebikes_2019
--6.84 Million rides

-- then to operate from this data - do I use the above code as a subquery under FROM?
--to keep the computation simpler, once I know the above UNION works - 
--write out codes to compute what I'm looking to do with one year's data in the from clause, then bring in
--the rest later

-- testing subqueries - median birth year of riders over 4 years

SELECT
	CASE
		WHEN user_birth_year is not null and when user_birth_year != '\N' Then 
FROM
	(SELECT *
		FROM BLUEBIKES_2016
		UNION SELECT *
		FROM BLUEBIKES_2017
		UNION SELECT *
		FROM BLUEBIKES_2018
		UNION SELECT *
		FROM BLUEBIKES_2019) as total_bluebike_data
		
		
--this query returns the station id of the most common start and end stations	
Select mode(total_bluebike_data.start_station_id) as Most_Common_Start_Station_ID, mode(total_bluebike_data.end_station_id) as Most_Common_End_Station_ID
--currently will not let me use mode()
--says it needs a within group for ordered set aggregate mode
from (SELECT *
		FROM public.bluebikes_2016
		UNION SELECT *
		FROM public.bluebikes_2017
		UNION SELECT *
		FROM public.bluebikes_2018
		UNION SELECT *
		FROM public.bluebikes_2019) as total_bluebike_data;
		
--total frequency of ride start occurences by station
-- this allows me to see the most popular ride start locations

select total_bluebike_data.start_station_id, stat.name, stat.district, count(start_time) as Sum_Rides
from --unioned table
(SELECT *
		FROM public.bluebikes_2016 -- this is all the bluebike data together
		UNION SELECT *
		FROM public.bluebikes_2017
		UNION SELECT *
		FROM public.bluebikes_2018
		UNION SELECT *
		FROM public.bluebikes_2019) as total_bluebike_data
JOIN bluebikes_stations as stat -- join the station info to the total ride data
ON total_bluebike_data.start_station_id = stat.id
group by start_station_id, stat.name, stat.district
order by count(start_time) desc
;

-- finding the most popular ride end station

select total_bluebike_data.end_station_id, stat.name, stat.district, count(end_time) as Sum_Rides
from --unioned table
(SELECT *
		FROM public.bluebikes_2016 -- this is all the bluebike data together
		UNION SELECT *
		FROM public.bluebikes_2017
		UNION SELECT *
		FROM public.bluebikes_2018
		UNION SELECT *
		FROM public.bluebikes_2019) as total_bluebike_data
JOIN bluebikes_stations as stat -- join the station info to the total ride data
ON total_bluebike_data.end_station_id = stat.id
group by end_station_id, stat.name, stat.district
order by count(end_time) desc
;

--most popular start and end times show a popularity within cambridge as a whole, MIT specifically
		

--Query idea: group rides into buckets - during what hours do most rides start/end?


--idea: overlay all rides on a map to find hotspots and dead zones
-- to start, join all geographic data to rides

select total_bluebike_data.start_time, total_bluebike_data.end_time, 
total_bluebike_data.start_station_id, start_stat.latitude, start_stat.longtitude,
--this is the id, lat and lon of the starting location
total_bluebike_data.end_station_id, end_stat.latitude, end_stat.longtitude
--id, and geographic data for end station
from -- unioned table
	(SELECT *
		FROM public.bluebikes_2016 -- this is all the bluebike data together
		UNION SELECT *
		FROM public.bluebikes_2017
		UNION SELECT *
		FROM public.bluebikes_2018
		UNION SELECT *
		FROM public.bluebikes_2019) as total_bluebike_data
left join bluebikes_stations as start_stat
on total_bluebike_data.start_station_id = start_stat.id
left join bluebikes_stations as end_stat
on total_bluebike_data.end_station_id = end_stat.id
limit 10000;
-- works in 9 sec - could potentially add in station names as well

--percentages of subscriber vs non-subscriber rides
--'Subscriber' vs 'Customer'

Select count(user_type)
from
(SELECT *
		FROM public.bluebikes_2016 -- this is all the bluebike data together
		UNION SELECT *
		FROM public.bluebikes_2017
		UNION SELECT *
		FROM public.bluebikes_2018
		UNION SELECT *
		FROM public.bluebikes_2019) as total_bluebike_data
--Where user_type ilike 'Subscriber';
--5,513,821 subscriber rides out of 6,840,320
--80.607% of rides were by a subscriber

--goal: return the frequency of a station showing up in either start or stop station section
--return station id, station name, total occurrences
--count(*) where station_id ilike station.id or station_id ilike endstation.id
--group by station id


select start_station_id, count(*)
from
	(select *
	from -- unioned table
		(SELECT *
			FROM public.bluebikes_2016 -- this is all the bluebike data together
			UNION SELECT *
			FROM public.bluebikes_2017
			UNION SELECT *
			FROM public.bluebikes_2018
			UNION SELECT *
			FROM public.bluebikes_2019) as total_bluebike_data
	left join bluebikes_stations as start_stat
	on total_bluebike_data.start_station_id = start_stat.id
	left join bluebikes_stations as end_stat
	on total_bluebike_data.end_station_id = end_stat.id
	) as total_bike_data
group by start_station_id
order by count(*) desc
limit 10000;


--ride frequency by neighborhood - not super helpful given how few districts they track
/*
select stat.district, count(start_time) as Sum_Rides
from --unioned table
(SELECT *
		FROM public.bluebikes_2016 -- this is all the bluebike data together
		UNION SELECT *
		FROM public.bluebikes_2017
		UNION SELECT *
		FROM public.bluebikes_2018
		UNION SELECT *
		FROM public.bluebikes_2019) as total_bluebike_data
JOIN bluebikes_stations as stat -- join the station info to the total ride data
ON total_bluebike_data.start_station_id = stat.id
group by stat.district
order by count(start_time) desc;

-- finding the most popular ride end neighborhood

select total_bluebike_data.end_station_id, stat.name, count(end_time) as Sum_Rides
from --unioned table
(SELECT *
		FROM public.bluebikes_2016 -- this is all the bluebike data together
		UNION SELECT *
		FROM public.bluebikes_2017
		UNION SELECT *
		FROM public.bluebikes_2018
		UNION SELECT *
		FROM public.bluebikes_2019) as total_bluebike_data
JOIN bluebikes_stations as stat -- join the station info to the total ride data
ON total_bluebike_data.end_station_id = stat.id
group by end_station_id, stat.name
order by count(end_time) desc; */


--how many stations are in each district?

select district, count(*)
from bluebikes_stations
group by district
order by count(*) desc;

--how many trips does a station see per year on average?

select (avg(trip_count)/4) as Yearly_avg_trips_per_station
--grouping total ride data by station id and then finding average of ride total counts
from
	(select start_station_id, count(*) as trip_count
	from
		(select *
		from -- unioned table
			(SELECT *
				FROM public.bluebikes_2016 -- this is all the bluebike data together
				UNION SELECT *
				FROM public.bluebikes_2017
				UNION SELECT *
				FROM public.bluebikes_2018
				UNION SELECT *
				FROM public.bluebikes_2019) as total_bluebike_data
		left join bluebikes_stations as start_stat
		on total_bluebike_data.start_station_id = start_stat.id
		left join bluebikes_stations as end_stat
		on total_bluebike_data.end_station_id = end_stat.id
		) as total_bike_data
	group by start_station_id
	order by count(*) desc) as total_rides
;
-- average annual trips/station 4,419
--what about just in cambridge?


--check if averages are skewed - min date for 2016, max date for 2020

select min(start_time)
from bluebikes_2016
;
--full year of 2016 data, min is 1/1/16

select max(start_time)
from bluebikes_2019
;

--full year of 2019, max date is 12/31

-- re-trying query as a CTE

WITH total_bluebike_data as (SELECT *
		FROM public.bluebikes_2016 -- this is all the bluebike data together
		UNION SELECT *
		FROM public.bluebikes_2017
		UNION SELECT *
		FROM public.bluebikes_2018
		UNION SELECT *
		FROM public.bluebikes_2019)


select total_bluebike_data.start_time, total_bluebike_data.end_time, 
total_bluebike_data.start_station_id, start_stat.latitude, start_stat.longtitude,
--this is the id, lat and lon of the starting location
total_bluebike_data.end_station_id, end_stat.latitude, end_stat.longtitude
--id, and geographic data for end station
from total_bluebike_data
left join bluebikes_stations as start_stat
on total_bluebike_data.start_station_id = start_stat.id
left join bluebikes_stations as end_stat
on total_bluebike_data.end_station_id = end_stat.id
limit 10000;

--adding zip code into station data

--return neighborhood, district, volume of rides (Start), start %, rides volume (end), end %


--cte 1
WITH station_data_updated as (Select *,

CASE --adding in data for neighborhoods
	--required excel to manually research coordinates and pull neighborhood names
	--and excel to compile code 'When, then, concat ''

WHEN	bluebikes_stations.number ilike	'A32019'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'S32035'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'S32023'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'M32026'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32054'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'V32001'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'B32060'	THEN	'Fenway'
WHEN	bluebikes_stations.number ilike	'M32060'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32064'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32058'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32065'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'A32032'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'C32061'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'M32046'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32033'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32079'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'M32059'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32037'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32012'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'B32004'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'D32004'	THEN	'Downtown Crossing'
WHEN	bluebikes_stations.number ilike	'C32048'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'C32062'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'S32018'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'A32003'	THEN	'Kenmore'
WHEN	bluebikes_stations.number ilike	'C32003'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'S32007'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'B32055'	THEN	'Roxbury Crossing'
WHEN	bluebikes_stations.number ilike	'D32024'	THEN	'Beacon Hill'
WHEN	bluebikes_stations.number ilike	'K32013'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'K32016'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'B32016'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'K32015'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'K32002'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'S32003'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'C32059'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'A32028'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'A32039'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'M32067'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32027'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32050'	THEN	'West End'
WHEN	bluebikes_stations.number ilike	'C32044'	THEN	'Mattapan'
WHEN	bluebikes_stations.number ilike	'B32008'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'D32018'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'A32036'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'A32045'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'C32002'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'D32044'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'B32031'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'D32007'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'D32013'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'D32055'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'D32046'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'C32008'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'B32034'	THEN	'Fenway'
WHEN	bluebikes_stations.number ilike	'B32018'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'B32013'	THEN	'Longwood'
WHEN	bluebikes_stations.number ilike	'D32028'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'A32005'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'V32011'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'S32016'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'V32004'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'V32008'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'S32014'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'C32053'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'K32005'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'K32003'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'A32023'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'B32020'	THEN	'Kenmore'
WHEN	bluebikes_stations.number ilike	'M32052'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32013'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32007'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32000'	THEN	'Beacon Hill'
WHEN	bluebikes_stations.number ilike	'M32019'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32088'	THEN	'Mattapan'
WHEN	bluebikes_stations.number ilike	'M32012'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32011'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'A32041'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'C32086'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'E32008'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'C32085'	THEN	'West Roxbury'
WHEN	bluebikes_stations.number ilike	'D32016'	THEN	'Beacon Hill'
WHEN	bluebikes_stations.number ilike	'D32039'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'A32027'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'V32009'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'M32049'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32015'	THEN	'Chinatown'
WHEN	bluebikes_stations.number ilike	'D32019'	THEN	'Chinatown'
WHEN	bluebikes_stations.number ilike	'B32005'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'S32010'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'D32047'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'B32035'	THEN	'Chestnut Hill'
WHEN	bluebikes_stations.number ilike	'C32055'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'B32006'	THEN	'Longwood'
WHEN	bluebikes_stations.number ilike	'B32029'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'C32052'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'C32077'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'A32002'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'K32006'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'D32033'	THEN	'Chestnut Hill'
WHEN	bluebikes_stations.number ilike	'A32017'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'D32034'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'S32022'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'D32009'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'C32032'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'C32010'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'S32004'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'K32001'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'W32001'	THEN	'Watertown'
WHEN	bluebikes_stations.number ilike	'D32005'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'S32037'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'D32010'	THEN	'North End'
WHEN	bluebikes_stations.number ilike	'E32001'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'K32009'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'M32030'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32031'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32045'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'S32006'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'B32037'	THEN	'Kenmore'
WHEN	bluebikes_stations.number ilike	'M32066'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32009'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'C32066'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'B32017'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'C32015'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'C32018'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'A32031'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'S32017'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'S32038'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'A32022'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'M32034'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'E32004'	THEN	'Roxbury Crossing'
WHEN	bluebikes_stations.number ilike	'S32039'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'V32005'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'V32003'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'A32000'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'A32038'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'C32051'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'C32041'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'E32010'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'S32015'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'C32037'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'C32027'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'C32030'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'M32051'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32040'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'C32090'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'V32006'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'A32034'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'B32032'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'M32068'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'E32005'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'B32028'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'S32019'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'V32012'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'D32043'	THEN	'Chinatown'
WHEN	bluebikes_stations.number ilike	'C32057'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'D32035'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'M32016'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32020'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32017'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32018'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32055'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32023'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32021'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32014'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32024'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32038'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32026'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'K32010'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'B32003'	THEN	'Longwood'
WHEN	bluebikes_stations.number ilike	'A32040'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'B32033'	THEN	'Longwood'
WHEN	bluebikes_stations.number ilike	'M32044'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32089'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'E32003'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'C32020'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'C32021'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'C32025'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'M32062'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'A32011'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'E32006'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'D32052'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'K32004'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'C32013'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'M32032'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32004'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'B32010'	THEN	'Kenmore'
WHEN	bluebikes_stations.number ilike	'M32065'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32009'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'B32015'	THEN	'Kenmore'
WHEN	bluebikes_stations.number ilike	'B32058'	THEN	'Fenway'
WHEN	bluebikes_stations.number ilike	'M32001'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32039'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32006'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'M32025'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'A32004'	THEN	'Longwood'
WHEN	bluebikes_stations.number ilike	'M32022'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'S32013'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'D32020'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'D32036'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'D32038'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'V32002'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'K32012'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'M32061'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32056'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32063'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'C32004'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'C32050'	THEN	'Mattapan'
WHEN	bluebikes_stations.number ilike	'C32045'	THEN	'Mattapan'
WHEN	bluebikes_stations.number ilike	'A32030'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'A32044'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'D32037'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'M32006'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32041'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32005'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32042'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'B32023'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'C23045'	THEN	'Mattapan'
WHEN	bluebikes_stations.number ilike	'M32043'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32080'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'D32017'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'C32023'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'M32045'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'W32003'	THEN	'Watertown'
WHEN	bluebikes_stations.number ilike	'A32025'	THEN	'West End'
WHEN	bluebikes_stations.number ilike	'B32027'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'D32001'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'B32000'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'C32022'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'C32078'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'B32012'	THEN	'Kenmore'
WHEN	bluebikes_stations.number ilike	'D32031'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'B32036'	THEN	'Longwood'
WHEN	bluebikes_stations.number ilike	'M32003'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32002'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32053'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'A32035'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'S32009'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'A32012'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'A32008'	THEN	'Kenmore'
WHEN	bluebikes_stations.number ilike	'D32042'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'C32039'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'S32034'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'A32029'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'M32029'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32012'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'S32008'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'C32007'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'A32026'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'M32036'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32058'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'M32035'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32047'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'C32046'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'D32008'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'C32001'	THEN	'Roxbury Crossing'
WHEN	bluebikes_stations.number ilike	'B32022'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'B32002'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'C32031'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'E32007'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'C32033'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'C32036'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'B32014'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'B32007'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'M32063'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32048'	THEN	'Chinatown'
WHEN	bluebikes_stations.number ilike	'E32009'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'M32047'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32032'	THEN	'Fenway'
WHEN	bluebikes_stations.number ilike	'A32006'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'S32001'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'S32036'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'S32020'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'C32017'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'A32009'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'A32010'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'D32023'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'C32087'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'K32007'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'C32024'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'D32041'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'D32049'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'D32011'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'D32053'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'A32013'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'A32042'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'V32007'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'C32064'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'C32043'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'K32008'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'S32011'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'E32011'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'A32033'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'C32028'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'D32054'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'C32049'	THEN	'Mattapan'
WHEN	bluebikes_stations.number ilike	'M32048'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32000'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'B32056'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'C32056'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'C32060'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'D32014'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'C32035'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'A32001'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'S32002'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'C32014'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'M32040'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32019'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'B32025'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'M32057'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32050'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32029'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'C32016'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'B32030'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'D32021'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'V32010'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'K32014'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'C32042'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'D32029'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'C32081'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'A32037'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'C32084'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'K32011'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'C32005'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'B32026'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'S32021'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'C32067'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'C32006'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'C32038'	THEN	'Mattapan'
WHEN	bluebikes_stations.number ilike	'C32083'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'D32002'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'C32034'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'W32002'	THEN	'Watertown'
WHEN	bluebikes_stations.number ilike	'B32021'	THEN	'Longwood'
WHEN	bluebikes_stations.number ilike	'D32022'	THEN	'West End'
WHEN	bluebikes_stations.number ilike	'A32043'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'B32059'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'D32040'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'S32005'	THEN	'Somerville'
ELSE 'Error'
END AS Neighborhood

FROM bluebikes_stations),

--cte 2

unioned_rider_data as (SELECT *
		FROM public.bluebikes_2016 -- this is all the bluebike data together
		UNION SELECT *
		FROM public.bluebikes_2017
		UNION SELECT *
		FROM public.bluebikes_2018
		UNION SELECT *
		FROM public.bluebikes_2019)
		

-- main query

select start_stat.neighborhood, start_stat.district, count(rides.start_time), count(distinct start_stat.id)
--return neighborhood, district, volume of rides (Start), start %, rides volume (end), end %
from unioned_rider_data as rides
left join station_data_updated as start_stat
on rides.start_station_id = start_stat.id
left join station_data_updated as end_stat
on rides.end_station_id = end_stat.id
group by 1,2
order by count(start_time) desc
;

--returning the average total rides per year
with four_year_rides as 
(Select *
		FROM public.bluebikes_2016 -- this is all the bluebike data together
		UNION SELECT *
		FROM public.bluebikes_2017
		UNION SELECT *
		FROM public.bluebikes_2018
		UNION SELECT *
		FROM public.bluebikes_2019)
		
Select count(four_year_rides.start_time)/4
from four_year_rides;


WITH station_data_updated as (Select *,

CASE --adding in data for neighborhoods
	--required excel to manually research coordinates and pull neighborhood names
	--and excel to compile code 'When, then, concat ''

WHEN	bluebikes_stations.number ilike	'A32019'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'S32035'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'S32023'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'M32026'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32054'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'V32001'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'B32060'	THEN	'Fenway'
WHEN	bluebikes_stations.number ilike	'M32060'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32064'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32058'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32065'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'A32032'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'C32061'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'M32046'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32033'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32079'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'M32059'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32037'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32012'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'B32004'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'D32004'	THEN	'Downtown Crossing'
WHEN	bluebikes_stations.number ilike	'C32048'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'C32062'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'S32018'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'A32003'	THEN	'Kenmore'
WHEN	bluebikes_stations.number ilike	'C32003'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'S32007'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'B32055'	THEN	'Roxbury Crossing'
WHEN	bluebikes_stations.number ilike	'D32024'	THEN	'Beacon Hill'
WHEN	bluebikes_stations.number ilike	'K32013'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'K32016'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'B32016'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'K32015'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'K32002'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'S32003'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'C32059'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'A32028'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'A32039'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'M32067'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32027'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32050'	THEN	'West End'
WHEN	bluebikes_stations.number ilike	'C32044'	THEN	'Mattapan'
WHEN	bluebikes_stations.number ilike	'B32008'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'D32018'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'A32036'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'A32045'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'C32002'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'D32044'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'B32031'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'D32007'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'D32013'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'D32055'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'D32046'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'C32008'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'B32034'	THEN	'Fenway'
WHEN	bluebikes_stations.number ilike	'B32018'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'B32013'	THEN	'Longwood'
WHEN	bluebikes_stations.number ilike	'D32028'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'A32005'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'V32011'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'S32016'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'V32004'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'V32008'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'S32014'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'C32053'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'K32005'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'K32003'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'A32023'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'B32020'	THEN	'Kenmore'
WHEN	bluebikes_stations.number ilike	'M32052'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32013'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32007'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32000'	THEN	'Beacon Hill'
WHEN	bluebikes_stations.number ilike	'M32019'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32088'	THEN	'Mattapan'
WHEN	bluebikes_stations.number ilike	'M32012'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32011'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'A32041'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'C32086'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'E32008'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'C32085'	THEN	'West Roxbury'
WHEN	bluebikes_stations.number ilike	'D32016'	THEN	'Beacon Hill'
WHEN	bluebikes_stations.number ilike	'D32039'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'A32027'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'V32009'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'M32049'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32015'	THEN	'Chinatown'
WHEN	bluebikes_stations.number ilike	'D32019'	THEN	'Chinatown'
WHEN	bluebikes_stations.number ilike	'B32005'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'S32010'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'D32047'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'B32035'	THEN	'Chestnut Hill'
WHEN	bluebikes_stations.number ilike	'C32055'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'B32006'	THEN	'Longwood'
WHEN	bluebikes_stations.number ilike	'B32029'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'C32052'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'C32077'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'A32002'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'K32006'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'D32033'	THEN	'Chestnut Hill'
WHEN	bluebikes_stations.number ilike	'A32017'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'D32034'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'S32022'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'D32009'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'C32032'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'C32010'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'S32004'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'K32001'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'W32001'	THEN	'Watertown'
WHEN	bluebikes_stations.number ilike	'D32005'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'S32037'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'D32010'	THEN	'North End'
WHEN	bluebikes_stations.number ilike	'E32001'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'K32009'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'M32030'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32031'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32045'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'S32006'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'B32037'	THEN	'Kenmore'
WHEN	bluebikes_stations.number ilike	'M32066'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32009'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'C32066'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'B32017'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'C32015'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'C32018'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'A32031'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'S32017'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'S32038'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'A32022'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'M32034'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'E32004'	THEN	'Roxbury Crossing'
WHEN	bluebikes_stations.number ilike	'S32039'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'V32005'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'V32003'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'A32000'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'A32038'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'C32051'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'C32041'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'E32010'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'S32015'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'C32037'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'C32027'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'C32030'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'M32051'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32040'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'C32090'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'V32006'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'A32034'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'B32032'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'M32068'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'E32005'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'B32028'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'S32019'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'V32012'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'D32043'	THEN	'Chinatown'
WHEN	bluebikes_stations.number ilike	'C32057'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'D32035'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'M32016'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32020'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32017'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32018'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32055'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32023'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32021'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32014'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32024'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32038'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32026'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'K32010'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'B32003'	THEN	'Longwood'
WHEN	bluebikes_stations.number ilike	'A32040'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'B32033'	THEN	'Longwood'
WHEN	bluebikes_stations.number ilike	'M32044'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32089'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'E32003'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'C32020'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'C32021'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'C32025'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'M32062'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'A32011'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'E32006'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'D32052'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'K32004'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'C32013'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'M32032'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32004'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'B32010'	THEN	'Kenmore'
WHEN	bluebikes_stations.number ilike	'M32065'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32009'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'B32015'	THEN	'Kenmore'
WHEN	bluebikes_stations.number ilike	'B32058'	THEN	'Fenway'
WHEN	bluebikes_stations.number ilike	'M32001'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32039'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32006'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'M32025'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'A32004'	THEN	'Longwood'
WHEN	bluebikes_stations.number ilike	'M32022'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'S32013'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'D32020'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'D32036'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'D32038'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'V32002'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'K32012'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'M32061'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32056'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32063'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'C32004'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'C32050'	THEN	'Mattapan'
WHEN	bluebikes_stations.number ilike	'C32045'	THEN	'Mattapan'
WHEN	bluebikes_stations.number ilike	'A32030'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'A32044'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'D32037'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'M32006'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32041'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32005'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32042'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'B32023'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'C23045'	THEN	'Mattapan'
WHEN	bluebikes_stations.number ilike	'M32043'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32080'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'D32017'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'C32023'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'M32045'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'W32003'	THEN	'Watertown'
WHEN	bluebikes_stations.number ilike	'A32025'	THEN	'West End'
WHEN	bluebikes_stations.number ilike	'B32027'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'D32001'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'B32000'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'C32022'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'C32078'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'B32012'	THEN	'Kenmore'
WHEN	bluebikes_stations.number ilike	'D32031'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'B32036'	THEN	'Longwood'
WHEN	bluebikes_stations.number ilike	'M32003'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32002'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32053'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'A32035'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'S32009'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'A32012'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'A32008'	THEN	'Kenmore'
WHEN	bluebikes_stations.number ilike	'D32042'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'C32039'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'S32034'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'A32029'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'M32029'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32012'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'S32008'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'C32007'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'A32026'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'M32036'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32058'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'M32035'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32047'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'C32046'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'D32008'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'C32001'	THEN	'Roxbury Crossing'
WHEN	bluebikes_stations.number ilike	'B32022'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'B32002'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'C32031'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'E32007'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'C32033'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'C32036'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'B32014'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'B32007'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'M32063'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32048'	THEN	'Chinatown'
WHEN	bluebikes_stations.number ilike	'E32009'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'M32047'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'D32032'	THEN	'Fenway'
WHEN	bluebikes_stations.number ilike	'A32006'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'S32001'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'S32036'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'S32020'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'C32017'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'A32009'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'A32010'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'D32023'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'C32087'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'K32007'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'C32024'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'D32041'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'D32049'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'D32011'	THEN	'Back Bay'
WHEN	bluebikes_stations.number ilike	'D32053'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'A32013'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'A32042'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'V32007'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'C32064'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'C32043'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'K32008'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'S32011'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'E32011'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'A32033'	THEN	'East Boston'
WHEN	bluebikes_stations.number ilike	'C32028'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'D32054'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'C32049'	THEN	'Mattapan'
WHEN	bluebikes_stations.number ilike	'M32048'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32000'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'B32056'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'C32056'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'C32060'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'D32014'	THEN	'Downtown'
WHEN	bluebikes_stations.number ilike	'C32035'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'A32001'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'S32002'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'C32014'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'M32040'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32019'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'B32025'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'M32057'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'M32050'	THEN	'Cambridge'
WHEN	bluebikes_stations.number ilike	'C32029'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'C32016'	THEN	'South Boston'
WHEN	bluebikes_stations.number ilike	'B32030'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'D32021'	THEN	'Charlestown'
WHEN	bluebikes_stations.number ilike	'V32010'	THEN	'Everett'
WHEN	bluebikes_stations.number ilike	'K32014'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'C32042'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'D32029'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'C32081'	THEN	'Roslindale'
WHEN	bluebikes_stations.number ilike	'A32037'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'C32084'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'K32011'	THEN	'Brookline'
WHEN	bluebikes_stations.number ilike	'C32005'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'B32026'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'S32021'	THEN	'Somerville'
WHEN	bluebikes_stations.number ilike	'C32067'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'C32006'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'C32038'	THEN	'Mattapan'
WHEN	bluebikes_stations.number ilike	'C32083'	THEN	'Dorchester'
WHEN	bluebikes_stations.number ilike	'D32002'	THEN	'South End'
WHEN	bluebikes_stations.number ilike	'C32034'	THEN	'Seaport'
WHEN	bluebikes_stations.number ilike	'W32002'	THEN	'Watertown'
WHEN	bluebikes_stations.number ilike	'B32021'	THEN	'Longwood'
WHEN	bluebikes_stations.number ilike	'D32022'	THEN	'West End'
WHEN	bluebikes_stations.number ilike	'A32043'	THEN	'Allston/Brighton'
WHEN	bluebikes_stations.number ilike	'B32059'	THEN	'Roxbury'
WHEN	bluebikes_stations.number ilike	'D32040'	THEN	'Jamaica Plain'
WHEN	bluebikes_stations.number ilike	'S32005'	THEN	'Somerville'
ELSE 'Error'
END AS Neighborhood

FROM bluebikes_stations),

--cte 2

unioned_rider_data as (SELECT *
		FROM public.bluebikes_2016 -- this is all the bluebike data together
		UNION SELECT *
		FROM public.bluebikes_2017
		UNION SELECT *
		FROM public.bluebikes_2018
		UNION SELECT *
		FROM public.bluebikes_2019)
		

-- main query

select start_stat.neighborhood, start_stat.district, count(rides.start_time), count(distinct start_stat.id)
--return neighborhood, district, volume of rides (Start), start %, rides volume (end), end %
from unioned_rider_data as rides
left join station_data_updated as start_stat
on rides.start_station_id = start_stat.id
left join station_data_updated as end_stat
on rides.end_station_id = end_stat.id
group by 1,2
order by count(start_time) desc
;

select count(*)
from bluebikes_stations
;
