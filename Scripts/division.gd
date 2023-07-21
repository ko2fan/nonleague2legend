extends Node

class_name Division

var division_id = -1

var fixtures = []
var results = []
var teams = []

func create_season_fixtures():
		var N = teams.size()
		for i in range(0, N - 1):
			var weekly_fixtures = []
			for x in range(0, N / 2):
				weekly_fixtures.append({ "home_team": (x + i) % N, "away_team": (N-1 - x + i) % N })
			fixtures.append(weekly_fixtures)
		
func get_league_table(season):
	var league = teams.duplicate()
	league.sort_custom(
		func(team_a, team_b):
			var pts_a = GameManager.teams[team_a].season_stats[season].wins * 3
			pts_a += GameManager.teams[team_a].season_stats[season].draws
			var pts_b = GameManager.teams[team_b].season_stats[season].wins * 3
			pts_b += GameManager.teams[team_b].season_stats[season].draws
			return pts_a > pts_b
	)
	return league 
	
