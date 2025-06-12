-- fonctions d'agrégation / aggregate functions

-- compte les lignes
select count(*) as nb_movie from movie; -- 1187

-- compte les valeurs sur une colonne
select count(title) as nb_title from movie; -- 1187 (title not null)
select count(duration) as nb_duration  from movie; -- 1181 (duration null)

-- compter les films qui n'ont pas de durée
select 
	count(*) as nb_movie_no_duration 
from movie 
where duration is null;

-- NB: arrondis: ceil, floor, round, trunc
select 
	count(*) as nb_movie,
	min(year) as min_year,
	max(year) as max_year,
	count(distinct year) as nb_year,
	count(distinct duration) as nb_duration,
	sum(duration) as total_duration,
	ceil(avg(duration)) as avg_duration
from movie;

select 
	min(birthdate) as min_birthdate,
	max(birthdate) as max_birthdate
from person;

select 
	count(*) as nb_person,
	count(distinct name) as nb_person_distinct,
	count(*) - count(distinct name) as nb_doubles
from person;
-- TODO: combien d'homonymes différents ?

-- dédoublonnage
select distinct
	year,
	duration
from movie;

-- compter après dédoublonnage sur plusieurs colonnes
select count(*) as nb_year_duration_distinct
from (
	select distinct
		year,
		duration
	from movie
);

with ydd as (
	select distinct
		year,
		duration
	from movie
)
select count(*) as nb_year_duration_distinct
from ydd;

select * from person where id = 11;


select * from pg_indexes where schemaname = 'public';

-- stats année 1987
select
	count(*) as nb_movie,
	min(duration) as min_duration,
	max(duration) as max_duration,
	avg(duration) as mean_duration,
	ceil(sum(duration) / 60) as total_duration_h,
	sum(char_length(title)) as total_letters
from movie
where year = 1987;

select 
	min(char_length(title)) as min_title_length,
	max(char_length(title)) as max_title_length
from movie;
-- TODO: which ones

select
	char_length(title) as title_length,
	year,
	title
from movie
where
	char_length(title) in (2, 208)
order by title_length;

-- agrégation + group by
select
	year,
	count(*) as nb_movie,
	min(duration) as min_duration,
	max(duration) as max_duration,
	ceil(avg(duration)) as mean_duration_mn,
	ceil(sum(duration) / 60) as total_duration_h,
	sum(char_length(title)) as total_letters
from movie
group by year
order by year;

select
	year,
	count(*) as nb_movie,
	min(duration) as min_duration,
	max(duration) as max_duration,
	ceil(avg(duration)) as mean_duration_mn,
	ceil(sum(duration) / 60) as total_duration_h,
	sum(char_length(title)) as total_letters
from movie
where year between 1980 and 1989 -- filtre avant group by
group by year
having count(*) >= 15  -- filtre après group by
order by nb_movie desc;


select 
	id,
	title,
	year,
	director_id
from movie
where year = 1988
order by director_id;

select * from person where id in (142, 217, 591, 1353);

-- stats par réalisateur (id uniquement): 
--  * nb films, 
--  * 1ère année, dernière année
--  * durées min, max, moy, total
-- tri par nb de réalisation décroissante
-- seuil à 10 réalisations min

select
	director_id,
	count(*) as nb_movie,
	min(year) as first_year,
	max(year) as last_year,
	sum(duration) as total_duration,
	avg(duration) as mean_duration
from movie
group by director_id
having count(*) >= 10
order by nb_movie desc;

-- jointures

-- films de 1982 avec leur réalisateur
select *
from 
	movie m
	join person d on m.director_id = d.id
where m.year = 1982;

select 
	m.id as movie_id,
	m.title,
	m.year,
	m.director_id,
	d.name
from 
	movie m
	join person d on m.director_id = d.id
where m.year = 1982
order by m.title;

-- filmographie en tant que réalisateur de Clint Eastwood (ordre chronologique inverse)
select 
	d.id as person_id,
	d.name,
	m.year,
	m.title
from
	person d
	inner join movie m on d.id = m.director_id
where
	d.name = 'Clint Eastwood'
order by m.year desc
;

-- NB: inner join = join (écritures équivalentes jointure interne)

select 
	d.id as person_id,
	d.name,
	m.year,
	m.title
from
	person d
	inner join movie m on d.id = m.director_id
where
	d.name = 'Clint Eastwood'
	and m.year >= 2000
order by m.year desc
;

-- autre écriture de la jointure
select 
	d.id as person_id,
	d.name,
	m.year,
	m.title
from
	person d,
	movie m
where
	-- condition de jointure
	d.id = m.director_id
	-- filtres
	and d.name = 'Clint Eastwood'
	and m.year >= 2000
order by m.year desc
;


-- les acteurs du film Blade Runner de 1982
select
	a.name,
	pl.role,
	m.title,
	m.year
from
	movie m
	join play pl on pl.movie_id = m.id
	join person a on a.id = pl.actor_id
where 
	m.title = 'Blade Runner'
	and m.year = 1982
order by a.name;

-- la filmographie des Harrison Ford
select
	a.id as person_id,
	a.name,
	pl.role,
	m.title,
	m.year
from
	movie m
	join play pl on pl.movie_id = m.id
	join person a on a.id = pl.actor_id
where 
	a.name = 'Harrison Ford'
order by person_id, m.year desc
;

-- liste des acteurs ayant joué James Bond (+ titre des films)
select
	m.year,
	a.name,
	pl.role,
	m.title
from
	movie m
	join play pl on pl.movie_id = m.id
	join person a on a.id = pl.actor_id
where 
	-- pl.role like '%James Bond%'
	pl.role in ('James Bond', 'Ian Fleming''s James Bond 007')
order by m.year;

select distinct 
	a.id, a.name
from
    play pl
	join person a on a.id = pl.actor_id
where pl.role in ('James Bond', 'Ian Fleming''s James Bond 007')
order by a.name;

select count(distinct pl.actor_id) as nb_actor_007
from play pl
where pl.role in ('James Bond', 'Ian Fleming''s James Bond 007');
