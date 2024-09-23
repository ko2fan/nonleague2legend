extends Node

class_name Division

var division_id := -1

var attendance_min := 0
var attendance_max := 0

var fixtures = []
var results = []
var teams = [] # Array of team_id

func remove_team(team_id: int):
	teams.erase(team_id)
	
func add_team(team_id: int):
	teams.append(team_id)

func create_season_fixtures():
	var N = teams.size()
	for i in range(0, N):
		var weekly_fixtures = []
		for x in range(0, N / 2):
			weekly_fixtures.append({ "home_team": (x + i) % N, "away_team": (N-1 - x + i) % N })
		fixtures.append(weekly_fixtures)
	for i in range(0, N):
		var weekly_fixtures = []
		for x in range((N / 2) + 1, N):
			weekly_fixtures.append({ "home_team": (x + i) % N, "away_team": (N-1 - x + i) % N })
		fixtures.append(weekly_fixtures)
		
func get_league_table(season : int):
	var static_teams = GameManager.get_teams()
	var league = teams.duplicate()
	league.sort_custom(
		func(team_a, team_b):
			var pts_a = static_teams[team_a].season_stats[season].wins * 3
			pts_a += static_teams[team_a].season_stats[season].draws
			var pts_b = static_teams[team_b].season_stats[season].wins * 3
			pts_b += static_teams[team_b].season_stats[season].draws
			if pts_a == pts_b:
				var gs_a = static_teams[team_a].season_stats[season].goals_scored
				var gc_a = static_teams[team_a].season_stats[season].goals_conceded
				var gs_b = static_teams[team_b].season_stats[season].goals_scored
				var gc_b =static_teams[team_b].season_stats[season].goals_conceded
				var gd_a = gs_a - gc_a
				var gd_b = gs_b - gc_b
				if gd_a == gd_b:
					return gs_a > gs_b
				return gd_a > gd_b
			return pts_a > pts_b
	)
	return league
	
# This will return a dictionary containing the team_id of the home team and away team
func get_fixture(week : int, team_id : int):
	for fixture in fixtures[week]:
		if teams[fixture["home_team"]] == team_id or teams[fixture["away_team"]] == team_id:
			return {"home_team": teams[fixture["home_team"]], "away_team": teams[fixture["away_team"]] }
	return {"home_team": 0, "away_team": 0 }
