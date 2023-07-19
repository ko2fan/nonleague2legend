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
		
