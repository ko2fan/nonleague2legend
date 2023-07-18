extends Node

class_name Team

var team_name = ""
var players = []

var division = 0
var season_stats

func get_players() -> Array:
	return players

func switch_players(player_one, player_two):
	var switch_player_one
	var switch_player_two
	for player in players:
		if player.squad_number == player_one:
			switch_player_one = player
		if player.squad_number == player_two:
			switch_player_two = player
			
	switch_player_one.squad_number = player_two
	switch_player_two.squad_number = player_one
	
	sort_players()
	
func sort_players():
	players.sort_custom(func(playera, playerb): \
		return playera.squad_number < playerb.squad_number)
