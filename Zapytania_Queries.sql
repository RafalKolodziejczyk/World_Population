/*
1.  Jak różnią się dane populacji krajów z obu źródeł? Które 10 krajów procentowo ma największą różnicę z obu źródeł danych w stosunku do populacji i ile ona wynosi?
    What is the difference in population from both data sources? Which 10 countries have the largest percentage difference of population from both data sources?
2.  Ile jest krajów na świecie, które mają większą zarówno liczbę ludności, jak i powierzchnię niż Polska?
    How many countries in the world have a larger population and area than Poland?
3.  Liczba mężczyzn w każdym kraju w 2020 roku.
    The number of men in each country in 2020.
4.  Czy na świecie jest więcej kobiet, czy mężczyzn?
    Are there more women or men in the world?
5.  Średnia ludności każdego kraju w każdej dekadzie XX wieku.
    Average population of each country in each decade of the 20th century.
6.  Liczba ludności 10 największych krajów (powierzchniowo) i ich stosunek procentowy do łącznej liczby ludności na świecie.
    Population of the 10 largest countries (by area) and their percentage to the total population in the world.
7.  Aktualny średni wiek w krajach, których ludność w 2000 roku wynosiła od 10 do 20 mln oraz gęstość zaludnienia w 2000 roku wynosiła od 100 do 200 osób/km2.
    The current average age in the countries whose population in 2000 was between 10 and 20 million and the population density in 2000 was between 100 and 200 people/km2.
8.  Ile najmniej ludnych krajów potrzeba aby ich ludność przewyższyła populację najludniejszego?
    How many least populous countries are needed to exceed population of the most populous country?
9.  Suma powierzchni jakich najmniejszych krajów da powierzchnię większą niż Polski?
    The sum of the areas of which of the smallest countries will give an area greater than area of Poland?
10. Lata, w których liczba ludności była większa niż średnia liczba ludności Polski w latach 2000-2010.
    Years when the population was greater than the average population of Poland in 2000-2010.
11. Jaki procent ludności świata w latach 1960-2020 stanowi ludność w 2020 roku?
    What percentage of the world population in the years 1960-2020 is the population in 2020?
12. W którym roku każdy kraj miał największą liczbę ludności i ile ona wynosiła?
    In which year each country had the largest population and how much was it?
13. W latach od 1960 do 2020 jakie kraje co roku miały najwięszy procent ludności poniżej 14 roku życia?
    Between 1960 and 2020, which countries had the highest percentage of the population under the age of 14 each year?
14. Które spośród 5 krajów o największym średnim wieku ludności i największym procentem osób powyżej 65 roku życia się pokrywają?
    Which of the 5 countries with the highest average population and the highest percentage of people over 65 overlap?
15. Ile krajów na miejscach 30-40 pod względem liczby ludności na świecie ma współczynnik dzietności powyżej średniego na świecie?
    How many countries in places 30-40 in terms of population in the world have a fertility rate above the world average?
16. Czy więcej krajów na świecie ma nazwę zaczynającą się od A do L, czy od M do Z?
    Do more countries in the world have names that start with A to L or M to Z?
17. Określenie czy kraj się starzeje na podstawie porównania liczby osób po 65 roku życia w 2010 roku i 2020 roku.
    Determining if a country is aging based on a comparison of the number of people over 65 in 2010 and 2020.
18. Czy w danym kraju większa jest populacja z 1960 roku zwiększona o 50%, czy obecna liczba ludności?
    Whether world countries population in 1960 increased by 50% is higher than the current countries population?
19. Kraj z najwyższym i najniższym współczynnikiem dzietności na świecie oraz tej wartości dla Polski.
    The country with the highest and the lowest fertility rate in the world and this value for Poland.
20. Zestawienie liczby ludności na świecie co 10 lat.
    Population in the world every 10 years.
21. 10 krajów, w których imigranci w 2020 roku stanowią największy odsetek liczby ludności.
    10 countries where immigrants represent the highest proportion of the population in 2020.
22. Ile ludzi żyłoby w największym kraju, gdyby przyjęto dla niego gęstość zaludnienia najgęściej zaludnionego kraju na świecie?
    How many people would live in the largest country, if it were taken to the population density of the most densely populated country in the world?
*/

--data repair by using joins
CREATE TABLE finished_general --IMPORTANT: AFTER EXECUTING CHANGE THE NAME OF THE TABLE TO finished_annual AND EXECUTE AGAIN
	AS WITH good_join AS ( 
		SELECT 
			gi.country AS general_country, 
			gi.population, ap.country AS annual_country, 
			ap.count
		FROM general_info AS gi
		JOIN annual_population AS ap
			ON ap.country = gi.country
		WHERE ap.year = 2020)

--not joined countries from general_info table
	, bad_join_general AS (
		SELECT 
			gi.country,
			gi.population
		FROM general_info AS gi
		LEFT JOIN good_join AS gj
			ON general_country = gi.country
		WHERE general_country IS NULL)

--not joined countries from annual_population table
	, bad_join_annual AS (
		SELECT 
			ap.country, 
			ap.year, 
			ap.count
		FROM annual_population AS ap
		LEFT JOIN good_join AS gj
			ON general_country = ap.country
		WHERE ap.year = 2020 
		AND general_country IS NULL)

--computation the maximum population difference ratio from general_info and annual_population
not joined countries from general_info table
	, max_pop_count_diff AS (
		SELECT 
			MAX(diff_ratio) AS max_diff_ratio 
		FROM (
			SELECT 
				general_country, 
				ROUND(abs(population-count) / ((population + count) / 2)::numeric, 2) AS diff_ratio
 			FROM good_join
 			GROUP BY general_country, population, count
			HAVING ROUND(abs(population-count) / ((population + count) / 2)::numeric, 2) IS NOT NULL
 			ORDER BY 2 DESC) 
		AS sub)

--joining not joined countries by first two name characters and first population digit
	, difference_joining AS (
		SELECT 
			bjg.country AS bjg_countries, 
			bjg.population, bja.country AS bja_countries, 
			bja.count
		FROM bad_join_general AS bjg
		JOIN bad_join_annual AS bja
			ON LEFT(bjg.country, 2) = LEFT(bja.country, 2)
		WHERE abs(population-count)/((population+count)/2)::numeric < (SELECT max_diff_ratio FROM max_pop_count_diff)
		AND LEFT(population::text, 1) = LEFT(count::text, 1)) 

--checking which countries from general_info table are still not joined
	, rest_joining1 AS (
		SELECT 
			bjg.country AS rest1_countries, 
			bjg.population AS rest1_population
		FROM difference_joining AS dj
		FULL OUTER JOIN bad_join_general AS bjg
			ON bjg.country = bjg_countries
		WHERE bjg_countries IS NULL)

--checking which countries from annual_population table are still not joined
	, rest_joining2 AS (
		SELECT 
			bja.country AS rest2_countries, 
			bja.count AS rest2_population
		FROM difference_joining AS dj
		FULL OUTER JOIN bad_join_annual AS bja
			ON bja.country = bja_countries
		WHERE bja_countries IS NULL)

--joining not joined countries by +-2% difference between both populations
	, rest_joining AS (
		SELECT 
			rest1_countries, 
			rest1_population, 
			rest2_countries, 
			rest2_population 
		FROM rest_joining1
		JOIN rest_joining2
			ON rest2_population BETWEEN rest1_population * 0.98 AND rest1_population * 1.02)

--joining of all successful joins
	, total_join AS (
		SELECT * FROM good_join
		UNION
		SELECT * FROM difference_joining
		UNION
		SELECT * FROM rest_joining)

--joining all tables with annual data
	, annual_joining AS (
		SELECT 
			ap.country, 
			ap.year, 
			ap.count AS population, 
			apd.count AS pop_density, 
			afp.percentage AS female_percentage,
			ap65.percentage AS above_age65_percentage, 
			ap14.percentage AS below_age14_percentage
		FROM annual_population AS ap
		JOIN annual_population_density AS apd
			ON apd.country = ap.country
		JOIN annual_female_population AS afp
			ON afp.country = ap.country
		JOIN annual_population_above_age65 AS ap65
			ON ap65.country = ap.country
		JOIN annual_population_below_age14 AS ap14
			ON ap14.country = ap.country
		WHERE apd.year = ap.year 
		AND afp.year = ap.year 
		AND ap65.year = ap.year 
		AND ap14.year = ap.year)

--final table with general info data
	, finished_general AS (
		SELECT gi.*, annual_country AS country2
		FROM general_info AS gi
		JOIN total_join AS tj
			ON tj.general_country = gi.country)

--final table with annual info data
	, finished_annual AS (
		SELECT aj.*, general_country AS country2
		FROM annual_joining AS aj
		JOIN total_join AS tj
			ON tj.annual_country = aj.country)

SELECT * FROM finished_general; --IMPORTANT: AFTER EXECUTING CHANGE THE NAME OF THE TABLE TO finished_annual AND EXECUTE AGAIN

--1. What is the difference in population from both data sources? Which 10 countries have the largest percentage difference of population from both data sources?
What is the difference in population from both data sources? Which 10 countries have the largest percentage difference of population from both data sources?
SELECT 
	fg.country, 
	fg.population, 
	fa.population, 
	abs(fg.population-fa.population) AS difference, 
	ROUND(abs(fg.population-fa.population)*100/GREATEST(fg.population, fa.population)::numeric, 2) AS percentage_diff
FROM finished_general AS fg
JOIN finished_annual AS fa
	ON fa.country2 = fg.country
WHERE fa.year = 2020 AND abs(fg.population-fa.population) IS NOT NULL
ORDER BY percentage_diff DESC
LIMIT 10;

--2. How many countries in the world have a larger population and area than Poland?
SELECT 
	COUNT(*)
FROM finished_general AS fg
WHERE population > (SELECT population FROM finished_general WHERE country = 'Poland')
AND land_area > (SELECT land_area FROM finished_general WHERE country = 'Poland');

--3. The number of men in each country in 2020.
SELECT 
	country, 
	floor((100-female_percentage) * population/100) AS male_population
FROM finished_annual
WHERE year = 2020;

--4. Are there more women or men in the world?
SELECT 
	female_population, 
	male_population, 
	CASE 
	WHEN female_population > male_population 
	THEN 'More female in the world'
	ELSE 'More male in the world'
	END	
FROM (	
	SELECT 
		SUM(floor(female_percentage * population/100)) AS female_population, 
		SUM((floor((100-female_percentage) * population/100))) AS male_population
	FROM finished_annual
	WHERE year = 2020) 
AS sub;

--5. Average population of each country in each decade of the 20th century.
SELECT 
	d1.country,
	ROUND(d1.avg, 2) AS _1960_1969,
	ROUND(d2.avg, 2) AS _1970_1979,
	ROUND(d3.avg, 2) AS _1980_1989,
	ROUND(d4.avg, 2) AS _1990_1999,
	ROUND(d5.avg, 2) AS _2000
FROM (
	SELECT 
		country, 
		AVG(population) AS avg
	FROM finished_annual
	WHERE year BETWEEN 1960 AND 1969
	GROUP BY 1) 
AS d1
LEFT JOIN (
	SELECT 
		country, 
		AVG(population) AS avg
	FROM finished_annual
	WHERE year BETWEEN 1970 AND 1979
	GROUP BY 1) 
AS d2
		ON d1.country=d2.country
LEFT JOIN (
	SELECT 
		country, 
		AVG(population) AS avg
	FROM finished_annual
	WHERE year BETWEEN 1980 AND 1989
	GROUP BY 1) 
AS d3
		ON d1.country=d3.country
LEFT JOIN (
	SELECT 
		country, 
		AVG(population) AS avg
	FROM finished_annual
	WHERE year BETWEEN 1990 AND 1999
	GROUP BY 1) 
AS d4
		ON d1.country=d4.country
LEFT JOIN (
	SELECT 
		country, 
		AVG(population) AS avg
	FROM finished_annual
	WHERE year = 2000 
	GROUP BY 1) 
AS d5
		ON d1.country=d5.country;
		
--6. Population of the 10 largest countries (by area) and their percentage to the total population in the world.
SELECT 
	SUM(d2.population) AS top10, 
	SUM(d1.population) AS world, 
	ROUND(SUM(d2.population) * 100 / SUM(d1.population)::numeric, 2) AS top10_percent
FROM (
	SELECT 
		country, 
		population 
	FROM finished_general) 
AS d1
LEFT JOIN (
	SELECT 
		country, 
		population 
	FROM finished_general 
	ORDER BY land_area DESC 
	LIMIT 10) 
AS d2
		ON d1.country = d2.country;
		
--7. The current average age in the countries whose population in 2000 was between 10 and 20 million and the population density in 2000 was between 100 and 200 people/km2.
	s1.country, 
	s3.medium_age, 
	s1.population, 
	s2.pop_density
FROM (
	SELECT 
		fg.country, 
		fa.population, 
		fa.year
 	FROM finished_general AS fg
JOIN finished_annual AS fa
 		ON fa.country2 = fg.country
 	WHERE year = 2000 
	AND fa.population BETWEEN 10000000 AND 20000000) 
AS s1
JOIN (
	SELECT 
		fg.country, 
		fa.pop_density, 
		fa.year
 	FROM finished_general AS fg
JOIN finished_annual AS fa
 		ON fa.country2 = fg.country
 	WHERE year = 2000 
	AND fa.pop_density BETWEEN 100 AND 200) 
AS s2
 		ON s2.country = s1.country
JOIN (
	SELECT fg.country, fg.medium_age
 	FROM finished_general AS fg) 
AS s3
 		ON s3.country = s1.country;

--8. How many least populous countries are needed to exceed population of the most populous country?
WITH cte_population AS (
	SELECT 
		country, 
		population, 
		SUM(population) OVER (ORDER BY population) AS total
	FROM  finished_general)

SELECT 
	COUNT(*) + 1 AS result
FROM cte_population
WHERE total < (SELECT MAX(population) FROM finished_general);

--9. The sum of the areas of which of the smallest countries will give an area greater than area of Poland?
WITH cte_area AS (
	SELECT 
		country, 
		land_area, 
		SUM(land_area) OVER (ORDER BY land_area) AS total
	FROM  finished_general)

SELECT * 
FROM (
	(SELECT * 
	FROM cte_area
	WHERE total < (SELECT land_area FROM finished_general WHERE country = 'Poland')) 
	
	UNION
	 
	(SELECT * 
	FROM cte_area
	WHERE total > (SELECT land_area FROM finished_general WHERE country = 'Poland')
	ORDER BY total
	LIMIT 1)) 
AS sub
	ORDER BY land_area;

--10. Years when the population was greater than the average population of Poland in 2000-2010.
SELECT 
	year, 
	country, 
	population
FROM finished_annual
WHERE population > (SELECT AVG(population) FROM finished_annual WHERE year BETWEEN 2000 AND 2010 AND country = 'Poland') 
AND country = 'Poland';

--11. What percentage of the world population in the years 1960-2020 is the population in 2020?
SELECT 
	ROUND(
	(SELECT SUM(population) AS sum2020 
 	FROM finished_annual
 	WHERE year = 2020) * 100
 	/ (SELECT SUM(population) AS sum
 	FROM finished_annual) 
 	, 2) 
	AS percent_2020_to_all;
	
--12. In which year each country had the largest population and how much was it?
SELECT 
	country, 
	population, 
	year
FROM (
	SELECT 
		country, 
		population, 
		year, 
		ROW_NUMBER() OVER (PARTITION BY country ORDER BY population DESC NULLS LAST) AS best
	FROM finished_annual) 
AS sub
WHERE best = 1;

--13. Between 1960 and 2020, which countries had the highest percentage of the population under the age of 14 each year?
SELECT 
	country, 
	year, 
	below_age14_percentage
FROM (
	SELECT 
		country, 
		year, 
		below_age14_percentage, 
		ROW_NUMBER() OVER (PARTITION BY year ORDER BY below_age14_percentage DESC NULLS LAST) AS best
	FROM finished_annual) 
AS sub
WHERE best = 1;

--14. Which of the 5 countries with the highest average population and the highest percentage of people over 65 overlap?
SELECT * 
FROM (
	(SELECT 
	  	country
	FROM finished_general
	ORDER BY medium_age DESC NULLS LAST
	LIMIT 5)
	
	INTERSECT
	
	(SELECT 
	 	country
	FROM finished_annual
	WHERE year = 2020
	ORDER BY above_age65_percentage DESC NULLS LAST
	LIMIT 5)
	) 
AS sub;

--15. How many countries in places 30-40 in terms of population in the world have a fertility rate above the world average?
SELECT 
	COUNT(*) 
FROM (
	SELECT 
		country, 
		fertility_rate
	FROM finished_general
	ORDER BY population DESC
	LIMIT 10 OFFSET 29) 
AS sub
WHERE fertility_rate > (SELECT AVG(fertility_rate) FROM finished_general);

--16. Do more countries in the world have names that start with A to L or M to Z?
SELECT 
	a_l, 
	m_z, 
	CASE
	WHEN a_l > m_z THEN 'More cuntries started with A-L than M-Z'
	WHEN a_l < m_z THEN 'Less cuntries started with A-L than M-Z'
	ELSE 'The same number of cuntries started with A-L as M-Z'
	END
FROM (
	SELECT
		(SELECT 
		 	COUNT(*) AS a_l 
	FROM finished_general
	WHERE LEFT(country, 1) BETWEEN 'A' AND 'L'),
		(SELECT 
		 	COUNT(*) AS m_z 
	FROM finished_general
	WHERE LEFT(country, 1) BETWEEN 'M' AND 'Z')
) AS sub;

--17. Determining if a country is aging based on a comparison of the number of people over 65 in 2010 and 2020.
SELECT
	s1.country,
	s1.a AS above65_2010,
	s2.a AS above65_2020,
	CASE
	WHEN s2.a > s1.a THEN 'Aging society (more developed countries)'
	WHEN s2.a < s1.a THEN 'Younger society (less developed countries)'
	ELSE 'No changes'
	END AS result
FROM (
	SELECT 
		country, 
		ROUND(above_age65_percentage::numeric, 2) AS a 
	FROM finished_annual
	WHERE year = 2010 AND above_age65_percentage IS NOT NULL) 
AS s1
LEFT JOIN (
	SELECT 
	 	country, 
	 	ROUND(above_age65_percentage::numeric, 2) AS a 
	FROM finished_annual
	WHERE year = 2020 AND above_age65_percentage IS NOT NULL) 
AS s2
		ON s2.country = s1.country;
		
--18. Whether world countries population in 1960 increased by 50% is higher than the current countries population?
SELECT 
	s1.country, 
	GREATEST(pop2020, pop1960 * 1.5), 
	CASE
	WHEN pop2020 > pop1960 * 1.5 THEN '50% increased population in 1960 is still less than in 2020'
	WHEN pop2020 < pop1960 * 1.5 THEN '50% increased population in 1960 is more than in 2020'
	ELSE 'Equal populations'
	END 
FROM (
	SELECT 
		country, 
		population AS pop1960 
	FROM finished_annual
 	WHERE year = 1960 AND population IS NOT NULL) 
AS s1
JOIN (
	(SELECT 
	 	country, 
	 	population AS pop2020 
	FROM finished_annual
	WHERE year = 2020 AND population IS NOT NULL) 
) AS s2
		ON s2.country = s1.country;
		
--19. The country with the highest and the lowest fertility rate in the world and this value for Poland.
SELECT * 
FROM (
	(SELECT 
	 	'Highest fertility rate' AS description, 
		country, 
		fertility_rate
	FROM finished_general
	ORDER BY fertility_rate DESC NULLS LAST
	LIMIT 1)
	
	UNION
	
	(SELECT 
	 	'Lowest fertility rate' AS description, 
		country, 
		fertility_rate  
	FROM finished_general
	ORDER BY fertility_rate
	LIMIT 1) 
	
	UNION
	
	(SELECT 
	 	'Poland fertility rate' AS description, 
		country, 
		fertility_rate  
	FROM finished_general
	WHERE country = 'Poland')
) AS sub;

--20. Population in the world every 10 years.
SELECT 
	'World population' AS description, 
	* 
FROM 
	(SELECT
		(SELECT 
			SUM(population) AS sum1960 
		FROM finished_annual
		WHERE year = 1960),
		(SELECT 
			SUM(population) AS sum1970 
		FROM finished_annual
		WHERE year = 1970),
		(SELECT 
			SUM(population) AS sum1980 
		FROM finished_annual
		WHERE year = 1980),
		(SELECT 
			SUM(population) AS sum1990 
		FROM finished_annual
		WHERE year = 1990),
 		(SELECT 
			SUM(population) AS sum2000 
		FROM finished_annual
		WHERE year = 2000),
		(SELECT 
			SUM(population) AS sum2010 
		FROM finished_annual
		WHERE year = 2010),
		(SELECT 
			SUM(population) AS sum2020 
		FROM finished_annual
		WHERE year = 2020)
) AS sub;
	
--21. 10 countries where immigrants represent the highest proportion of the population in 2020.
SELECT 
	country, 
	ROUND(migrants::numeric * 100 / population::numeric, 2) AS percentage_migrants 
FROM finished_general
ORDER BY percentage_migrants DESC NULLS LAST
LIMIT 10;

--22. How many people would live in the largest country, if it were taken to the population density of the most densely populated country in the world?
SELECT
	(SELECT 
		country AS largest_country
	FROM finished_general
	ORDER BY land_area DESC NULLS LAST
	LIMIT 1),
	(SELECT 
		MAX(land_area) AS max_area
	FROM finished_general),
	(SELECT 
		MAX(density) AS max_density
	FROM finished_general),
	(SELECT 
		MAX(density) * MAX(land_area) AS population_if
	FROM finished_general);

--EXPORT OF TABLES TO CSV FILES TO MAKE VISUALIZATION IN THE POWER BI
COPY finished_annual TO 'C:/RoadTo15k/Projekt_demografia/finished_annual.csv' WITH (FORMAT CSV, HEADER);
COPY finished_general TO 'C:/RoadTo15k/Projekt_demografia/finished_general.csv' WITH (FORMAT CSV, HEADER);
