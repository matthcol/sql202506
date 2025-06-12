-- Requête de base
SELECT * FROM person;
select * from movie;

-- Filtrer: sélection WHERE
SELECT * FROM movie WHERE year = 1984;

-- Projection
SELECT title, year FROM movie;

-- titre, année et durée des films de 2010
SELECT 
	title, 
	year, 
	duration 
FROM movie
WHERE year = 2010
ORDER BY title;

-- + filtre durée >= 120
SELECT 
	title, 
	year, 
	duration 
FROM movie
WHERE 
	year = 2010
	AND duration >= 120
ORDER BY title;

-- + filtre durée entre 2H et 4H
SELECT 
	title, 
	year, 
	duration 
FROM movie
WHERE 
	year = 2010
	AND duration BETWEEN 120 AND 240
ORDER BY title;

-- Operateurs de comparaison
--   égal: = 
--   différent: <>  !=
--   +grand, +petit: <  <=  >  >=
--   intervalle: BETWEEN

SELECT
	title, 
	year, 
	duration 
FROM movie
WHERE duration != 120
ORDER BY duration DESC;

SELECT
	title, 
	year, 
	duration 
FROM movie
WHERE duration <> 120
ORDER BY duration DESC;

-- Information absente ou présente
SELECT
	title, 
	year, 
	duration 
FROM movie
WHERE duration IS NULL;

SELECT
	title, 
	year, 
	duration 
FROM movie
WHERE duration IS NOT NULL;

SELECT
	title, 
	year, 
	duration 
FROM movie
WHERE 
	duration IS NULL
	OR duration = 0;

SELECT
	title, 
	year, 
	duration 
FROM movie
WHERE year IN (1984, 2010, 2015)
ORDER BY year, title;

SELECT
	title, 
	year, 
	duration 
FROM movie
WHERE
	year BETWEEN 1980 AND 2020
	AND year NOT IN (1984, 2010, 2015)
ORDER BY year, title;

SELECT
	title, 
	year, 
	duration 
FROM movie
WHERE 
	NOT ( 
		year = 2010
		AND duration >= 120
	);

SELECT
	title, 
	year, 
	duration 
FROM movie
WHERE 
	year != 2010
	OR duration < 120;

SELECT
	title,
	year,
	duration,
	-- colonnes calculées:
	duration / 60 as duration_h,
	duration % 60 as duration_mn
FROM movie
WHERE year = 2010;

-- titre (année) des films des années 80
SELECT
	CONCAT(title, ' (', year, ')') as title_year
FROM movie
WHERE year = 1984;

SELECT
	title || ' (' || year || ')' as title_year
FROM movie
WHERE year = 1984;

SELECT
	title, 
	year
FROM movie
WHERE
	title = 'Gremlins';

-- remake
SELECT
	title, 
	year
FROM movie
WHERE
	title = 'The Man Who Knew Too Much';

SELECT
	title, 
	year,
	year < 1950 as before_50
FROM movie
WHERE
	title like 'The Man Who %';

-- NB: par défaut, PostgreSQL est sensible à la casse

SELECT
	title, 
	year,
	year < 1950 as before_50
FROM movie
WHERE
	title like 'the man %'; -- no results

SELECT
	title, 
	year,
	year < 1950 as before_50
FROM movie
WHERE
	title ilike 'the man %'; -- ilike = like case insensitive

-- films dont le titre contient 'night'
-- NB: + fin => regex (expression régulière) ou fulltext search
SELECT
	title,
	year
FROM movie
WHERE title ilike '%night%'
ORDER BY title;

SELECT
	title,
	year
FROM movie
WHERE title ~* '(^|[^a-z])nights?($|[^a-z])'
ORDER BY title;

SELECT
	title,
	char_length(title) as title_length,
	upper(title) as title_u,
	lower(title) as title_l,
	substring(title FOR 3) as title_first_3,
	upper(substring(title FROM 3 FOR 3)) as title_3_3,
	-- position(' ' in title) as pos_first_space,
	-- substring(title FOR position(' ' in title)) as first_word0,
	case 
		when position(' ' in title) > 0 then substring(title FOR position(' ' in title))
		else title
	end as first_word
FROM movie
WHERE year = 1998;

-- 
SELECT 2^14 / 365;

-- données temporelles
SELECT
	name,
	birthdate
FROM person
WHERE name like 'Fred%';

show datestyle; -- ISO,MDY

SELECT
	name,
	birthdate
FROM person
WHERE birthdate = '1899-05-10'; -- Fred Astaire

SELECT
	name,
	birthdate
FROM person
WHERE birthdate = '10/05/1899'; -- no one avec datestyle MDY, interprété 5 octobre

-- Setting pour ce script
set datestyle = ISO,DMY;
show datestyle;

SELECT
	name,
	birthdate
FROM person
WHERE birthdate = '1899-05-10';

SELECT
	name,
	birthdate
FROM person
WHERE birthdate = '10/05/1899'; -- OK pour format français: 10 mai

SELECT name FROM person WHERE name like '%é%';

SELECT * FROM person;

SELECT
	name,
	birthdate,
	to_char(birthdate, 'DD/MM/YYYY')
FROM person 
WHERE 
	name like '%é%'
	AND birthdate IS NOT NULL;

-- Personnes nées entre:
-- * date départ 1er janvier 1970
-- * date de fin 28 décembre 1998
SELECT *
FROM person
WHERE birthdate BETWEEN '1970-01-01' AND '1998-12-28'
ORDER BY birthdate;

SELECT 
	title,
	year,
	duration,
	duration / 60.0 as duration_hour
FROM movie
WHERE duration / 60.0 < 1.2
ORDER BY duration;

-- explicit conversion (technique Postgres, suffixe ::type)
SELECT
	title,
	duration::numeric,
	year::int,
	'2000-01-01'::date
FROM movie
WHERE title ilike '%star%'; 

-- 'date' système
SELECT
	CURRENT_DATE,
	CURRENT_TIME,
	CURRENT_TIMESTAMP;

-- age au 31/12
SELECT 
	name,
	birthdate,
	-- YEAR(birthdate) -- OK MariaDB, MSSQL, ..
	EXTRACT(year FROM birthdate) as birth_year,
	DATE_PART('year', birthdate) as birth_year2,
	EXTRACT(year FROM current_date) - EXTRACT(year FROM birthdate) as age_end_year,
	AGE(current_date, birthdate) as age
FROM person
WHERE name like 'Jack %';

SELECT *
FROM person
WHERE birthdate >= (current_date - '20 years'::interval)
ORDER BY birthdate DESC;


SELECT 
	name,
	birthdate,
	AGE(current_date, birthdate) as person_age,
	CASE
		WHEN AGE(current_date, birthdate) < '20 years' THEN 'MOINS 20'
		WHEN AGE(current_date, birthdate) < '40 years' THEN 'MOINS 40'
		WHEN AGE(current_date, birthdate) < '60 years' THEN 'MOINS 60'
		ELSE 'PLUS 60'
	END as categorie_age
FROM person
WHERE 
	(name like 'G%' OR name like 'J%')
	AND birthdate IS NOT NULL
ORDER BY categorie_age;

SELECT 
	name,
	birthdate,
	person_age,
	case
		when person_age < '20 years' then 'MOINS 20'
		when person_age < '40 years' then 'MOINS 40'
		when person_age < '60 years' then 'MOINS 60'
		else 'PLUS 60'
	end as categorie_age
FROM (
	SELECT 
		name,
		birthdate,
		AGE(current_date, birthdate) as person_age
	FROM person
	WHERE 
		(name like 'G%' OR name like 'J%')
		AND birthdate IS NOT NULL
) 
ORDER BY categorie_age;


-- sous-requete(s)
with p as (
	SELECT 
		name,
		birthdate,
		AGE(current_date, birthdate) as person_age
	FROM person
	WHERE 
		(name like 'G%' OR name like 'J%')
		AND birthdate IS NOT NULL
) 
-- Requete principale
SELECT 
	name,
	birthdate,
	person_age,
	case
		when person_age < '20 years' then 'MOINS 20'
		when person_age < '40 years' then 'MOINS 40'
		when person_age < '60 years' then 'MOINS 60'
		else 'PLUS 60'
	end as categorie_age
FROM p
ORDER BY categorie_age;









	

















