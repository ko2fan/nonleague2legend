extends Node

var divisions = []
var teams = []
var players = []

var current_season = 0
var current_week = 0
var human_index
var next_player_slot = 0
var loaded_game = false
var next_team_slot = 0

var initials = [ "A", "B", "C", "D", "D", "E", "F", "G", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "R", "S", "S", "T", "T", "V", "W" ]

func _init():
	randomize()
	
func new_game():
	var database : JSON = preload("res://data/database.json")

	var team_data = database.data["divisions"]
	var player_data = database.data["surnames"]
	
	create_teams(team_data)
	create_players(player_data)
	
	assign_players_to_teams()
	
	create_fixtures()
	
func create_teams(team_data):
	var next_division_slot = 0
	for division in team_data:
		var div = Division.new()
		div.division_id = next_division_slot
		divisions.append(div)
		next_division_slot += 1
		for team_name in division["teams"]:
			var team = Team.new()
			team.team_id = next_team_slot
			team.team_name = team_name["team_name"]
			team.division = div.division_id
			var team_stats = TeamStats.new()
			team_stats.played = 0
			team_stats.wins = 0
			team_stats.draws = 0
			team_stats.goals_conceded = 0
			team_stats.goals_scored = 0
			team.season_stats.append(team_stats)
			teams.append(team)
			next_team_slot += 1
			div.teams.append(team.team_id)
		
func create_players(player_data):
	for i in 640:
		var name_generator = generate_name(player_data)
		var player = generate_player(name_generator)
		players.append(player)
		next_player_slot += 1
		
func generate_name(surname_list):
	return initials.pick_random() + ". " + surname_list.pick_random()
	
func generate_player(player_name):
	var player = Player.new()
	player.player_name = player_name
	return player
	
func assign_players_to_teams():
	var player_index = 0
	for team in teams:
		for i in 16:
			var player = players[player_index]
			player.squad_number = i
			player.team = team
			team.players.append(player)
			player_index += 1

func create_profile():
	new_game()

func get_teams():
	return teams

func set_player_index(team_name):
	for index in teams.size():
		if teams[index].team_name == team_name:
			human_index = index
			break

func get_player_team():
	return teams[human_index]

func save_game():
	var save_file = FileAccess.open("user://savefile.nl", FileAccess.WRITE)
	var version = 0x4
	save_file.store_32(version)
	save_file.store_32(human_index)
	save_file.store_32(current_season)
	save_file.store_32(current_week)
	save_file.store_32(divisions.size())
	for division in divisions:
		save_file.store_32(division.division_id)
		save_file.store_32(division.teams.size())
		for team_id in division.teams:
			save_file.store_32(team_id)
		save_file.store_32(division.fixtures.size())
		for weekly_fixtures in division.fixtures:
			save_file.store_32(weekly_fixtures.size())
			for fixture in weekly_fixtures:
				save_file.store_32(fixture["home_team"])
				save_file.store_32(fixture["away_team"])
		save_file.store_32(division.results.size())
		for weekly_results in division.results:
			save_file.store_32(weekly_results.size())
			for result in weekly_results:
				save_file.store_32(result["home_team"])
				save_file.store_8(result["home_score"])
				save_file.store_32(result["away_team"])
				save_file.store_8(result["away_score"])
	save_file.store_32(teams.size())
	for team in teams:
		save_file.store_32(team.team_id)
		save_file.store_pascal_string(team.team_name)
		save_file.store_8(team.division)
		save_file.store_32(team.season_stats.size())
		for team_stats in team.season_stats:
			save_file.store_8(team_stats.played)
			save_file.store_8(team_stats.wins)
			save_file.store_8(team_stats.draws)
			save_file.store_8(team_stats.goals_scored)
			save_file.store_8(team_stats.goals_conceded)
	save_file.store_32(players.size())
	for player in players:
		save_file.store_pascal_string(player.player_name)
		save_file.store_8(player.squad_number)
		if player.team != null:
			save_file.store_32(player.team.team_id)
		else:
			save_file.store_32(4294967295)
	save_file.close()
	
func load_game():
	var load_file = FileAccess.open("user://savefile.nl", FileAccess.READ)
	var version = load_file.get_32()
	match version:
		0x3:
			human_index = load_file.get_32()
			current_season = load_file.get_32()
			current_week = load_file.get_32()
			var num_divisions = load_file.get_32()
			for i in num_divisions:
				var division = Division.new()
				division.division_id = load_file.get_32()
				var num_teams = load_file.get_32()
				for j in num_teams:
					division.teams.append(load_file.get_32())
				var num_weekly_fixtures = load_file.get_32()
				for k in num_weekly_fixtures:
					var num_fixtures = load_file.get_32()
					var weekly_fixtures = []
					for f in num_fixtures:
						var home_team = load_file.get_32()
						var away_team = load_file.get_32()
						var fixture = { "home_team": home_team, "away_team": away_team }
						weekly_fixtures.append(fixture)
					division.fixtures.append(weekly_fixtures)
				var num_weekly_results = load_file.get_32()
				for l in num_weekly_results:
					var weekly_results = []
					var num_results = load_file.get_32()
					for r in num_results:
						var home_team = load_file.get_32()
						var home_score = load_file.get_8()
						var away_team = load_file.get_32()
						var away_score = load_file.get_8()
						var result = { "home_team": home_team, "home_score": home_score,
							"away_team": away_team, "away_score": away_score }
						weekly_results.append(result)
					division.results.append(weekly_results)
				divisions.append(division)
			var num_teams = load_file.get_32()
			for i in num_teams:
				var team = Team.new()
				team.team_id = load_file.get_32()
				team.team_name = load_file.get_pascal_string()
				team.division = load_file.get_8()
				teams.append(team)
			var num_players = load_file.get_32()
			for i in num_players:
				var player = Player.new()
				player.player_name = load_file.get_pascal_string()
				player.squad_number = load_file.get_8()
				var team_id = load_file.get_32()
				if team_id != 4294967295:
					var player_team = teams.filter(func(team): return team.team_id == team_id).front()
					player_team.players.append(player)
					player.team = player_team
				players.append(player)
		0x4:
			human_index = load_file.get_32()
			current_season = load_file.get_32()
			current_week = load_file.get_32()
			var num_divisions = load_file.get_32()
			for i in num_divisions:
				var division = Division.new()
				division.division_id = load_file.get_32()
				var num_teams = load_file.get_32()
				for j in num_teams:
					division.teams.append(load_file.get_32())
				var num_weekly_fixtures = load_file.get_32()
				for k in num_weekly_fixtures:
					var num_fixtures = load_file.get_32()
					var weekly_fixtures = []
					for f in num_fixtures:
						var home_team = load_file.get_32()
						var away_team = load_file.get_32()
						var fixture = { "home_team": home_team, "away_team": away_team }
						weekly_fixtures.append(fixture)
					division.fixtures.append(weekly_fixtures)
				var num_weekly_results = load_file.get_32()
				for l in num_weekly_results:
					var weekly_results = []
					var num_results = load_file.get_32()
					for r in num_results:
						var home_team = load_file.get_32()
						var home_score = load_file.get_8()
						var away_team = load_file.get_32()
						var away_score = load_file.get_8()
						var result = { "home_team": home_team, "home_score": home_score,
							"away_team": away_team, "away_score": away_score }
						weekly_results.append(result)
					division.results.append(weekly_results)
				divisions.append(division)
			var num_teams = load_file.get_32()
			for i in num_teams:
				var team = Team.new()
				team.team_id = load_file.get_32()
				team.team_name = load_file.get_pascal_string()
				team.division = load_file.get_8()
				var num_stats = load_file.get_32()
				for team_stats in num_stats:
					var stat = TeamStats.new()
					stat.played = load_file.get_8()
					stat.wins = load_file.get_8()
					stat.draws = load_file.get_8()
					stat.goals_scored = load_file.get_8()
					stat.goals_conceded = load_file.get_8()
					team.season_stats.append(stat)
				teams.append(team)
			var num_players = load_file.get_32()
			for i in num_players:
				var player = Player.new()
				player.player_name = load_file.get_pascal_string()
				player.squad_number = load_file.get_8()
				var team_id = load_file.get_32()
				if team_id != 4294967295:
					var player_team = teams.filter(func(team): return team.team_id == team_id).front()
					player_team.players.append(player)
					player.team = player_team
				players.append(player)
	load_file.close()
	loaded_game = true


func create_fixtures():
	for division in divisions:
		division.create_season_fixtures()
		
func get_fixture(division_id, team_id):
	var fixtures = divisions[division_id].fixtures[current_week]
	for fixture in fixtures:
		if fixture["home_team"] == team_id or fixture["away_team"] == team_id:
			return fixture
			
	print("Error, fixture not found")
	return { "home_team": 0, "away_team": 0 }

func get_team_in_division(division_id, team_id):
	var division = divisions[division_id]
	if team_id < division.teams.size():
		return teams[division.teams[team_id]]
	print("Invalid team id")
	return null

func get_division_team_id(division_id, team_id):
	var division = divisions[division_id]
	var finding_team = teams[team_id]
	var index = 0
	for team in division.teams:
		if finding_team.team_id == teams[team].team_id:
			return index
		index += 1
	return 0
	
func play_matches():
	for division in divisions:
		var weekly_results = []
		for fixture in division.fixtures[current_week]:
			var home_team_id = fixture["home_team"]
			var home_score = randi_range(0, 6)
			var away_team_id = fixture["away_team"]
			var away_score = randi_range(0, 5)
			var result = { "home_team": home_team_id, "home_score": home_score,
				"away_team": away_team_id, "away_score": away_score }
			weekly_results.append(result)
			var home_team = get_team_in_division(division.division_id, home_team_id) as Team
			home_team.add_result(home_score, away_score)
			var away_team = get_team_in_division(division.division_id, away_team_id) as Team
			away_team.add_result(away_score, home_score)
		division.results.append(weekly_results)
	
func get_results():
	var results = []
	for division in divisions:
		results.append(division.results[current_week])
	return results

func finish_week():
	current_week += 1		
	if (current_week > divisions[teams[human_index].division].fixtures.size()):
		finish_season()
		
func finish_season():
	current_season += 1
	current_week = 0

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		for team in teams:
			for team_stats in team.season_stats:
				team_stats.queue_free()
			team.queue_free()
		for player in players:
				player.queue_free()
#		for season in seasons:
#			season.queue_free()
		for division in divisions:
			division.queue_free()
		get_tree().quit()
