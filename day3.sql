-- day 3

-- sous requetes indépendantes

-- réalisateurs: 540
select *
from person p
where p.id in (
	select m.director_id
	from movie m
);

-- acteurs
select * 
from person
where id in (
	select actor_id from play
);

-- réalisateurs et acteurs: 151
select *
from person p
where 
	id in (
		select director_id from movie
	)
	and id in (
		select actor_id from play
	)
order by name;

select *
from person p
where p.id in (
	select m.director_id
	from movie m
)
intersect
select * 
from person
where id in (
	select actor_id from play
);


-- réalisateurs mais pas acteurs: 389
select *
from person p
where p.id in (
	select m.director_id
	from movie m
)
except
select * 
from person
where id in (
	select actor_id from play
);
-- NB: autre sol utiliser IN et NOT IN


-- acteurs mais pas réalisateurs: 46877
select *
from person
where id in (
	select actor_id from play
)
except
select * 
from person
where id in (
	select m.director_id
	from movie m
)
;

-- ni acteur ni réalisateur
select *
from person p
where 
	id not in (
		select director_id from movie
	)
	and id not in (
		select actor_id from play
	)
order by name;


-- recap opérateurs ensemblistes: INTERSECT, UNION, EXCEPT

-- sous-requête dépendante
-- réalisateurs
select *
from person p
where exists (
	select *
	from movie m
	where m.director_id = p.id
);
-- pas réalisateurs
select *
from person p
where not exists (
	select *
	from movie m
	where m.director_id = p.id
);


-- gestion des valeurs nulles
-- filtres: prédicats IS NULL, IS NOT NULL
-- remplacer: fonction COALESCE (attention => contenu homogène par colonne)

select 
	p.name,
	COALESCE(p.birthdate, '1700-01-01') as birthdate
from person p;

select 
	p.name,
	COALESCE(p.birthdate::varchar, 'Inconnue') as birthdate
from person p;

select 
	p.name,
	COALESCE(to_char(p.birthdate, 'dd/mm/yyyy'), 'Inconnue') as birthdate
from person p;

-- sous requetes avec WITH
with movie_clint as (
	select
		m.id as movie_id,
		m.title,
		m.year,
		m.duration,
		m.director_id,
		d.name
	from 
		movie m
		join person d on m.director_id = d.id
	where
		d.name = 'Clint Eastwood'
)
-- les acteurs ayant joué dans les films de clint eastwood
select
	pl.actor_id,
	a.name,
	pl.role,
	movie_clint.*
from
	person a
	join play pl on pl.actor_id = a.id
	join movie_clint on pl.movie_id = movie_clint.movie_id
order by a.name, movie_clint.year
;
-- idem: en précisant le nombre de participations
with movie_clint as (
	select
		m.id as movie_id,
		m.title,
		m.year,
		m.duration,
		m.director_id,
		d.name as director_name
	from 
		movie m
		join person d on m.director_id = d.id
	where
		d.name = 'Clint Eastwood'
), actors_movie_clint as (
	select
		pl.actor_id,
		a.name as actor_name,
		pl.role,
		movie_clint.*
	from
		person a
		join play pl on pl.actor_id = a.id
		join movie_clint on pl.movie_id = movie_clint.movie_id
)
-- DEBUG: select *  from actors_movie_clint order by actor_id;
select
	actor_id, 
	actor_name,
	count(movie_id) as nb_movie
from actors_movie_clint
group by actor_id, actor_name
having count(movie_id) >= 2
order by nb_movie desc
;

-- films de l'année 2000 avec leurs genres
select *
from movie
where year = 2000;

select
	m.id,
	m.title,
	m.year,
	m.duration,
	hg.genre
from
	movie m
	join have_genre hg on hg.movie_id = m.id
where m.year = 2000
order by m.title; 

-- + filtre: genre Thriller
select
	m.id,
	m.title,
	m.year,
	m.duration,
	hg.genre
from
	movie m
	join have_genre hg on hg.movie_id = m.id
where 
	m.year = 2000
	and hg.genre = 'Thriller'
order by m.title; 

-- 
select
	m.id,
	m.title,
	m.year,
	m.duration,
	string_agg(hg.genre, ', ') as genres
from
	movie m
	join have_genre hg on hg.movie_id = m.id
where m.year = 2000
group by m.id -- , m.title, m.year, m.duration -- (CADEAU PostgreSQL pour les colonnes de la même table que la PK)
order by m.title; 

select
	m.id,
	m.title,
	m.year,
	m.duration,
	string_agg(hg.genre, ', ' order by hg.genre) as genres
from
	movie m
	join have_genre hg on hg.movie_id = m.id
where m.year = 2000
group by m.id 
order by m.title; 


-- Verif max year
select max(year) from movie; -- 2020

-- Ajout d'un nouveau filme
INSERT INTO movie (title, year) VALUES ('La venue de l''avenir', 2025); 
-- réponse: INSERT 0 1
-- id généré automatiquement
select * from movie where year = 2025;

INSERT INTO movie (title, year) VALUES (123, 2025); -- title conversion implicite

-- invalid input syntax for type smallint
-- INSERT INTO movie (title, year) VALUES ('un film', 'une année');

-- duplicate key value violates unique constraint "uniq_movie"
-- INSERT INTO movie (title, year) VALUES ('La venue de l''avenir', 2025); 

-- ERROR:  new row for relation "movie" violates check constraint "chk_movie_year"
-- INSERT INTO movie (title, year) VALUES ('La venue de l''avenir', 1789);

-- null value in column "year" of relation "movie" violates not-null constraint
-- INSERT INTO movie (title) VALUES ('pas d''année');

select * from movie where year = 2025;

select * from movie where id = 8079250;
delete from movie where id = 8079250; -- réponse: DELETE 1

select * from movie where year = 2025;

select * from person where name like '% Klapisch';
insert into person (name, birthdate) values ('Cédric Klapisch', '1961-09-04');
select * from person where name like '% Klapisch'; -- id: 11903874
select * from movie where id = 8079249; -- La venue de l'avenir

update movie set director_id = 11903874 where id = 8079249; -- réponse: UPDATE 1
select * from movie where id = 8079249;

select 
	m.id,
	m.title,
	m.year,
	m.director_id,
	d.id,
	d.name
from
	movie m
	join person d on d.id = m.director_id
where m.year = 2025;

-- UPDATE "La venue de l'avenir" en précisant:
--  * la durée 124
--  * synopsis: "Une famille doit décider ce qu'elle doit faire du vestige de leur ancêtre."
update movie 
set 
	duration = 124,
	synopsis = 'Une famille doit décider ce qu''elle doit faire du vestige de leur ancêtre.'
where id = 8079249; -- UPDATE 1

select * from movie where year = 2025;

select * 
from person 
where name in (
	'Suzanne Lindon'
	'Abraham Wapler'
	'Vincent Macaigne'
	'Julia Piaton'
	'Pomme',
	'Vassili Schneider'
);

insert into person (name) values
	('Suzanne Lindon'),
	('Abraham Wapler'),
	('Vincent Macaigne'),
	('Julia Piaton'),
	('Pomme'),
	('Vassili Schneider')
returning id, name  -- PostgreSQL only
;

insert into play (movie_id, actor_id, role)
values
	(8079249,11903881, 'Adèle Meunier née Vermillard'),
	(8079249,11903882, 'Seb, Claude Monet 1874'),
	(8079249,11903883, 'Guy'),
	(8079249,11903884, 'Céline'),
	(8079249,11903885, 'Fleur'),
	(8079249,11903886, 'Lucien');
-- INSERT 0 6

select 
  pl.movie_id,
  m.title,
  pl.actor_id,
  a.name,
  pl.role
from
	movie m
	join play pl on pl.movie_id = m.id
	join person a on a.id = pl.actor_id
where m.title like 'La venue%';

insert into movie (title, year, director_id)
values 
	('Le Secret de Khéops', 2025, NULL),
	('God Save the Tuche', 2025, NULL),
	('Juror #2', 2024, 142),
	('Killers of the Flower Moon', 2023, 217)
; -- INSERT 0 4

select 
	m.id, 
	m.title, 
	m.year, 
	m.duration,
	m.director_id
from movie m
where year >= 2023;

-- jointure interne:  JOIN eq INNER JOIN
select 
	m.id, 
	m.title, 
	m.year, 
	m.duration,
	m.director_id,
	d.name
from 
	movie m
	join person d on d.id = m.director_id
where year >= 2023;

-- jointure externe: LEFT (OUTER), RIGHT (OUTER), FULL (OUTER)
select 
	m.id, 
	m.title, 
	m.year, 
	m.duration,
	m.director_id,
	d.name
from 
	movie m
	left join person d on d.id = m.director_id
where year >= 2023;

-- selection de personnes connues
select * 
from person
where
	name in (
		'Gérard Depardieu',
		'Ingrid Bergman',
		'Kirk Douglas',
		'Meryl Streep',
		'Steve McQueen',
		'Martin Scorsese'
	);

with person_selection as (
	select * 
	from person
	where
		name in (
			'Gérard Depardieu',
			'Ingrid Bergman',
			'Kirk Douglas',
			'Meryl Streep',
			'Steve McQueen',
			'Martin Scorsese'
		)
), stats_director as (
	select 
		d.id, d.name, d.birthdate,
		count(m.id) as nb_movie_directed, -- OK: 0 si pas de réalisation
		coalesce(sum(m.duration), 0) as total_duration_directed
	from 
		person_selection d 	
		left join movie m on m.director_id = d.id
	group by d.id, d.name, d.birthdate
), stats_actor as (
	select 
		a.id, a.name, a.birthdate,
		count(m.id) as nb_movie_played, 
		coalesce(sum(m.duration), 0) as total_duration_played
	from
		person_selection a
		left join play pl on a.id = pl.actor_id
		left join movie m on pl.movie_id = m.id
	group by a.id, a.name, a.birthdate
)
-- fusionner les 2 tableaux
select 
	std.*,
	sta.nb_movie_played,
	sta.total_duration_played,
	std.nb_movie_directed + sta.nb_movie_played as total_credit
from 
	stats_director std
	join stats_actor sta on std.id = sta.id
order by std.name, std.id
;




 



















