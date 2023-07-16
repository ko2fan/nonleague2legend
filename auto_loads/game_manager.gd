extends Node

class_name GameManager

static var teams = []
static var current_season = 0
static var player_index

static func _static_init():
	randomize()
	var database : JSON = preload("res://data/database.json")

	var team_data = database.data["divisions"]
	
	create_teams(team_data)
	create_players()
	
static func create_teams(team_data):
	for division in team_data:
		for team_name in division["teams"]:
			var team = Team.new()
			team.team_name = team_name["team_name"]
			teams.append(team)
		
static func create_players():
	pass
	
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
