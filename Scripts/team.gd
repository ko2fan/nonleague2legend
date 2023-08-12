extends Node

class_name Team

var team_id = -1
var team_name = ""
var players = []

var division = -1
var season_stats = []

var formation = GameManager.Formation.FORMATION_4_4_2
var finances

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

func add_result(our_score, their_score):
	var stats = season_stats.back() as TeamStats
	stats.played += 1
	if our_score > their_score:
		stats.wins += 1
	elif our_score == their_score:
		stats.draws += 1
	stats.goals_scored += our_score
	stats.goals_conceded += their_score
