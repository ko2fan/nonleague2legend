extends Node

class_name GameManager

static var teams = []
static var players = []

static var current_season = 0
static var player_index
static var next_player_slot = 0

static var initials = [ "A", "B", "C", "D", "D", "E", "F", "G", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "R", "S", "S", "T", "T", "V", "W" ]

static func _static_init():
	randomize()
	var database : JSON = preload("res://data/database.json")

	var team_data = database.data["divisions"]
	var player_data = database.data["surnames"]
	
	create_teams(team_data)
	create_players(player_data)
	
	assign_players_to_teams()
	
static func create_teams(team_data):
	for division in team_data:
		for team_name in division["teams"]:
			var team = Team.new()
			team.team_name = team_name["team_name"]
			teams.append(team)
		
static func create_players(player_data):
	for i in 640:
		var name_generator = generate_name(player_data)
		var player = generate_player(name_generator)
		players.append(player)
		next_player_slot += 1
		
static func generate_name(surname_list):
	return initials.pick_random() + ". " + surname_list.pick_random()
	
static func generate_player(player_name):
	var player = Player.new()
	player.player_name = player_name
	return player
	
static func assign_players_to_teams():
	var player_index = 0
	for team in teams:
		for i in 16:
			var player = players[player_index]
			player.squad_number = i
			player.team = team
			team.players.append(player)
			player_index += 1

static func create_profile():
	print("Create profile here")

static func get_teams():
	return teams

static func set_player_index(team_name):
	for index in teams.size():
		if teams[index].team_name == team_name:
			player_index = index
			break

static func get_player_team():
	return teams[player_index]
