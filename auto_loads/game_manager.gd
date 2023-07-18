extends Node

var teams = []
var players = []

var current_season = 0
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
	
func create_teams(team_data):
	for division in team_data:
		for team_name in division["teams"]:
			var team = Team.new()
			team.team_id = next_team_slot
			team.team_name = team_name["team_name"]
			teams.append(team)
			next_team_slot += 1
		
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
	var version = 0x1
	save_file.store_32(version)
	save_file.store_32(human_index)
	save_file.store_32(current_season)
	save_file.store_32(teams.size())
	for team in teams:
		save_file.store_32(team.team_id)
		save_file.store_pascal_string(team.team_name)
		save_file.store_8(team.division)
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
		0x1:
			human_index = load_file.get_32()
			current_season = load_file.get_32()
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
					print(team_id)
					var player_team = teams.filter(func(team): return team.team_id == team_id).front()
					player_team.players.append(player)
					player.team = player_team
				players.append(player)
	load_file.close()
	loaded_game = true
