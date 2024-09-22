extends Node

class_name Team

var team_id = -1
var team_name = ""
var players = []

var division = -1
var season_stats = []

var formation = GameManager.Formation.FORMATION_4_4_2
var finances

var avg_price = 0

func get_players() -> Array:
	return players
	
func get_picked_players() -> Array:
	return players.filter(func(player): return player.squad_number < 11)
	
func get_team_size():
	return players.size()

func get_player(squad_number):
	sort_players()
	return players[squad_number]

func get_finances():
	return finances

func switch_players(player_one, player_two):
	var switch_player_one
	var switch_player_two
	for player in players:
		if player.squad_number == player_one:
			switch_player_one = player
		if player.squad_number == player_two:
			switch_player_two = player
		if switch_player_one != null && switch_player_two != null:
			break
			
	switch_player_one.squad_number = player_two
	switch_player_two.squad_number = player_one
	
	sort_players()

func sell_player(squad_number, sell_price):
	finances.current_money += sell_price
	remove_player(squad_number)

func remove_player(squad_number):
	var player_to_remove = null
	for player in players:
		if player.squad_number == squad_number:
			player_to_remove = player
		if player.squad_number > squad_number:
			player.squad_number -= 1
	if player_to_remove != null:
		player_to_remove.team = null
		players.erase(player_to_remove)
	
	sort_players()

func sort_players():
	players.sort_custom(func(playera, playerb): \
		return playera.squad_number < playerb.squad_number)

func add_result(result):
	var stats = season_stats.back() as TeamStats
	stats.played += 1
	var is_home = GameManager.get_team_in_division(division, result["home_team"]).team_id == team_id
	var home_goals = result["home_team_goals"]
	var away_goals = result["away_team_goals"]
	if home_goals == away_goals:
		stats.draws += 1
	if is_home:
		if home_goals > away_goals:
			stats.wins += 1
		stats.goals_scored += home_goals
		stats.goals_conceded += away_goals
	else:
		if home_goals < away_goals:
			stats.wins += 1
		stats.goals_scored += away_goals
		stats.goals_conceded += home_goals
