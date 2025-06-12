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