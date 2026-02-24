extends Node

class_name Division

var division_id := -1

var attendance_min := 0
var attendance_max := 0

var fixtures := []
var results := []
var teams := [] # Array of team_id

func remove_team(team_id: int):
	teams.erase(team_id)
	
func add_team(team_id: int):
	teams.append(team_id)

func create_season_fixtures():
	# Round-robin: each team plays every other twice (home and away). Circle method.
	# https://pimvanthof.github.io/rr.pdf
	var N := teams.size()
	if N < 2:
		return
	# Use even n (add dummy/bye if odd)
	var n := N if (N % 2 == 0) else N + 1
	var num_rounds_first_half := n - 1
	# First half: rounds 0..num_rounds_first_half-1; second half: same pairings, home/away swapped
	for round in range(2 * num_rounds_first_half):
		var weekly_fixtures: Array = []
		var r := round % num_rounds_first_half
		# Team 0 (index 0) plays opponent (n-1 - r)
		var opp0 := n - 1 - r
		if opp0 < N:
			var home_idx := 0 if round < num_rounds_first_half else opp0
			var away_idx := opp0 if round < num_rounds_first_half else 0
			weekly_fixtures.append({ "home_team": home_idx, "away_team": away_idx })
		# Circle of teams 1..n-1 in rotated order; exclude opp0 (already paired with team 0)
		var rest: Array = []
		for p in range(n - 1):
			var team_idx := ((p + r) % (n - 1)) + 1
			if team_idx != opp0:
				rest.append(team_idx)
		# Pair rest[j] with rest[rest.size()-1-j]
		for j in range(rest.size() / 2):
			var a : int = rest[j]
			var b : int = rest[rest.size() - 1 - j]
			if a < N and b < N:  # skip bye if n > N
				var home_idx := a if round < num_rounds_first_half else b
				var away_idx := b if round < num_rounds_first_half else a
				weekly_fixtures.append({ "home_team": home_idx, "away_team": away_idx })
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

func get_results_for_team(team_id : int) -> Array:
	var team_results := []
	for week in results:
		var result = week.filter(
			func(res):
				return GameManager.get_team_in_division(division_id, res["home_team"]).team_id == team_id or \
					GameManager.get_team_in_division(division_id, res["away_team"]).team_id == team_id
		)
		if result.is_empty() == false:
			team_results.append(result.front())
	return team_results
