extends Node

var game_data

var loaded_game = false
var game_started = false
var max_team_size = 20

@onready var bid_player = preload("res://Scenes/bid_player.tscn")
@onready var match_event_prefab = preload("res://Scenes/match_event.tscn")
@onready var match_stat_prefab = preload("res://Scenes/match_stat.tscn")

var old_scene
var queued_bids = []
	
var positional_colour = {
	"GK" = Color.LAWN_GREEN,
	"DEF" = Color.DEEP_SKY_BLUE,
	"MID" = Color.YELLOW,
	"ATT" = Color.CRIMSON
}

enum Formation {
	FORMATION_4_4_2 = 0,
	FORMATION_4_5_1 = 1,
	FORMATION_4_3_3 = 2,
	FORMATION_5_3_2 = 3
}

enum PlayingPosition {
	ANY = 0,
	GK = 1,
	DEF = 2,
	MID = 4,
	ATT = 8
}

var common_positions = [ PlayingPosition.GK, PlayingPosition.DEF, PlayingPosition.DEF,
	PlayingPosition.DEF, PlayingPosition.DEF + PlayingPosition.MID, PlayingPosition.MID,
	PlayingPosition.MID, PlayingPosition.MID, PlayingPosition.MID + PlayingPosition.ATT,
	PlayingPosition.ATT, PlayingPosition.ATT ]

func _init():
	randomize()
	
func new_game():
	game_data = GameData.new()
	var team_data = game_data.load_data()
	
	create_teams(team_data)
	create_players()
	assign_players_to_teams()
	create_fixtures()
	
func create_teams(team_data):
	var next_division_slot = 0
	for division in team_data:
		var div = Division.new()
		div.division_id = next_division_slot
		div.attendance_min = division["attendance_min"]
		div.attendance_max = division["attendance_max"]
		game_data.divisions.append(div)
		next_division_slot += 1
		for team_name in division["teams"]:
			var team = game_data.create_team(
				team_name["team_name"],
				div.division_id,
				Formation.values().pick_random(),
				randf_range(division["price_min"], division["price_max"])
			)
			div.teams.append(team.team_id)

func create_players():
	var num_gks = 0
	var num_defs = 0
	var num_mids = 0
	var num_atts = 0
	var filled = false
	while not filled:
		var player = game_data.create_player(common_positions.pick_random())
		match player.player_position:
			1:
				num_gks += 1
			2,6:
				num_defs += 1
			4,6,12:
				num_mids += 1
			8,12:
				num_atts += 1
		var size: int = game_data.teams.size()
		if num_gks >= 3 * size + 10 and \
			num_defs >= 7 * size + 60 and \
			num_mids >= 6 * size + 50 and \
			num_atts >= 4 * size + 30:
				filled = true
		

	
func get_week():
	return game_data.current_week
	
func get_season():
	return game_data.current_season
	
func assign_players_to_teams():
	var unassigned_players = game_data.players.duplicate()
	var keepers = unassigned_players.filter(func(player): return player.player_position == PlayingPosition.GK)
	
	var min_defenders = 0
	var max_defenders = 0
	var min_midfielders = 0
	var max_midfielders = 0
	var min_attackers = 0
	var max_attackers = 0
	
	for team in game_data.teams:
		match team.formation:
			Formation.FORMATION_4_4_2:
				min_defenders = 4
				max_defenders = 6
				min_midfielders = 4
				max_midfielders = 5
				min_attackers = 2
				max_attackers = 3
			Formation.FORMATION_4_5_1:
				min_defenders = 4
				max_defenders = 5
				min_midfielders = 5
				max_midfielders = 7
				min_attackers = 1
				max_attackers = 2
			Formation.FORMATION_4_3_3:
				min_defenders = 4
				max_defenders = 6
				min_midfielders = 3
				max_midfielders = 4
				min_attackers = 3
				max_attackers = 4
			Formation.FORMATION_5_3_2:
				min_defenders = 5
				max_defenders = 7
				min_midfielders = 3
				max_midfielders = 4
				min_attackers = 2
				max_attackers = 3
		
		# assign keepers
		for i in 1:
			var player = keepers.pop_front()
			add_player_to_team(player, team)
			unassigned_players.erase(player)
			
		# assign defenders
		var defenders = unassigned_players.filter(
			func(player):
				return player.player_position == PlayingPosition.DEF or \
					player.player_position == 6)
		for i in min_defenders:
			var player = defenders.pop_front()
			add_player_to_team(player, team)
			unassigned_players.erase(player)
			
		# assign midfielders
		var midfielders = unassigned_players.filter(
			func(player):
				return player.player_position == PlayingPosition.MID or \
					player.player_position == 6 or player.player_position == 12)
		for i in min_midfielders:
			var player = midfielders.pop_front()
			add_player_to_team(player, team)
			unassigned_players.erase(player)
			
		# assign sttackers
		var attackers = unassigned_players.filter(
			func(player):
				return player.player_position == PlayingPosition.ATT or \
					player.player_position == 12)
		for i in min_attackers:
			var player = attackers.pop_front()
			add_player_to_team(player, team)
			unassigned_players.erase(player)
		
		# now add reserves
		
		# assign keepers
		for i in 1:
			var player = keepers.pop_front()
			add_player_to_team(player, team)
			unassigned_players.erase(player)
			
		# assign defenders
		var reserve_defenders = unassigned_players.filter(
			func(player):
				return player.player_position == PlayingPosition.DEF or \
					player.player_position == 6)
		for i in (max_defenders - min_defenders):
			var player = reserve_defenders.pop_front()
			add_player_to_team(player, team)
			unassigned_players.erase(player)
			
		# assign midfielders
		var reserve_midfielders = unassigned_players.filter(
			func(player):
				return player.player_position == PlayingPosition.MID or \
					player.player_position == 6 or player.player_position == 12)
		for i in (max_midfielders - min_midfielders):
			var player = reserve_midfielders.pop_front()
			add_player_to_team(player, team)
			unassigned_players.erase(player)
			
		# assign sttackers
		var reserve_attackers = unassigned_players.filter(
			func(player):
				return player.player_position == PlayingPosition.ATT or \
					player.player_position == 12)
		for i in (max_attackers - min_attackers):
			var player = reserve_attackers.pop_front()
			add_player_to_team(player, team)
			unassigned_players.erase(player)
			
func add_player_to_team(player, team):
	player.team = team
	player.squad_number = team.players.size()
	team.players.append(player)
	team.sort_players()

func create_profile():
	new_game()

func get_division(division_id: int):
	return game_data.divisions[division_id]

func get_teams():
	return game_data.teams

func set_player_index(team_name):
	for index in game_data.teams.size():
		if game_data.teams[index].team_name == team_name:
			game_data.human_index = index
			break

func get_last_division():
	return game_data.divisions.back()

func move_team_to_division(team, division_index):
	var old_division_index = team.division
	team.division = division_index
	var division = game_data.divisions[division_index]
	division.add_team(team.team_id)
	var division_old = game_data.divisions[old_division_index]
	division_old.remove_team(team.team_id)

func get_player_team() -> Team:
	return game_data.teams[game_data.human_index]
	
func get_team(team_id) -> Team:
	for team in game_data.teams:
		if team.team_id == team_id:
			return team
	return null
	
func create_fixtures():
	for division in game_data.divisions:
		division.create_season_fixtures()
		
func get_fixture(division_id, team_id):
	var division = game_data.divisions[division_id]
	var fixture = division.get_fixture(game_data.current_week, team_id)
	
	if (fixture["home_team"] == 0 or fixture["away_team"] == 0):
		print("Error, fixture not found")
		return null
	return fixture

func get_team_in_division(division_id : int, team_id : int):
	var division = game_data.divisions[division_id]
	if team_id < division.teams.size():
		return game_data.teams[division.teams[team_id]]
	print("Invalid team id")
	return null

func get_division_team_id(division_id, team_id):
	var division = game_data.divisions[division_id]
	var finding_team = game_data.teams[team_id]
	var index = 0
	for team in division.teams:
		if finding_team.team_id == game_data.teams[team].team_id:
			return index
		index += 1
	return 0
	
func get_player_by_id(player_id):
	return game_data.players.filter(func(player): return player.player_id == player_id).front()
	
func play_matches():
	for division in game_data.divisions:
		var weekly_results = []
		for fixture in division.fixtures[game_data.current_week]:
			var home_team_id = fixture["home_team"]
			var away_team_id = fixture["away_team"]
			
			var home_team = get_team_in_division(division.division_id, home_team_id) as Team
			var away_team = get_team_in_division(division.division_id, away_team_id) as Team
			
			var result = play_match(home_team, away_team)
			weekly_results.append(result)
			
			home_team.add_result(result)
			away_team.add_result(result)
		division.results.append(weekly_results)

func play_match(home_team : Team, away_team : Team):
	var home_goals = 0
	var away_goals = 0
	var events = []
	var stats = match_stat_prefab.instantiate()
	var division = game_data.divisions[home_team.division]
	
	for player : Player in home_team.get_players().filter(func(player): return player.suspended >= 1):
		player.suspended -= 1
	for player : Player in away_team.get_players().filter(func(player): return player.suspended >= 1):
		player.suspended -= 1
	
	# in 1990 lowest attendance was 1,139
	# highest 47,245
	# as per: https://european-football-statistics.co.uk/attn/archive/eng/aveeng1990.htm
	stats.attendance = randi_range(division.attendance_min, division.attendance_max)
	
	var home_bookings = assign_bookings(home_team)
	var away_bookings = assign_bookings(away_team)
	
	var yellows = home_bookings["yellow_cards"] + away_bookings["yellow_cards"]
	var reds = home_bookings["red_cards"] + away_bookings["red_cards"]
	
	for yellow in yellows:
		var player = yellow["player"]
		var minute = yellow["minute"]
		player.yellow_cards += 1
		if player.yellow_cards == 5:
			player.suspended = 1
		if player.yellow_cards == 10:
			player.suspended = 2
		var event = create_booking_event(player.team.team_id, player.player_id, minute)
		events.append(event)
		
	for red in reds:
		var player: Player = red["player"]
		var minute: int = red["minute"]
		player.suspended = 1
		var event = create_sendingoff_event(player.team.team_id, player.player_id, minute)
		events.append(event)
	
	create_half_time_event()
	
	# home team
	var home_skill = home_team.get_picked_players().map(func(player): return player.player_skill).reduce(func(acc, sum): return acc + sum)
	var away_skill = home_team.get_picked_players().map(func(player): return player.player_skill).reduce(func(acc, sum): return acc + sum)
	
	var home_stats = assign_stats_events(home_team, home_skill)
	var away_stats = assign_stats_events(away_team, away_skill)
	
	var home_shots :int = home_stats["shots"]
	var home_shots_on :Array = home_stats["shots_on_target"]
	var home_corners :Array = home_stats["corners"]
	stats.home_shots_off_target = home_shots - home_shots_on.size()
	stats.home_shots_on_target = home_shots_on.size()
	
	var away_shots :int = away_stats["shots"]
	var away_shots_on :Array = away_stats["shots_on_target"]
	var away_corners :Array = away_stats["corners"]
	stats.away_shots_off_target = away_shots - away_shots_on.size()
	stats.away_shots_on_target = away_shots_on.size()
	
	for shots_on in home_shots_on + away_shots_on:
		var player = shots_on["player"]
		var event = create_shotontarget_event(player.team.team_id, player.player_id, shots_on["minute"])
		events.append(event)
		
	for corners in home_corners + away_corners:
		var player = corners["player"]
		var event = create_corner_event(player.team.team_id, player.player_id, corners["minute"])
		events.append(event)
		
	var skill_difference = abs(home_skill - away_skill)

	if skill_difference == 0:
		home_goals = randi_range(0, min(3, stats.home_shots_on_target))  # Equal match
		away_goals = randi_range(0, min(3, stats.away_shots_on_target))
	elif home_skill > away_skill:
		home_goals = min(5, randi_range(1, min(5, stats.home_shots_on_target)) + skill_difference / 10)
		away_goals = randi_range(0, min(home_goals + 1, stats.away_shots_on_target))
	else:
		away_goals = min(5, randi_range(1, min(5, stats.away_shots_on_target)) + skill_difference / 10)
		home_goals = randi_range(0, min(away_goals + 1, stats.home_shots_on_target))

	# Step 6: Randomly assign who scored the goals and at what minute
	for goals in home_goals:
		var shots_on = home_shots_on.duplicate()
		var player_scored = home_team.get_picked_players().filter(
			func(player):
				return player.player_position != PlayingPosition.GK
		).pick_random()
		player_scored.goals_scored += 1
		
		var random_shot = shots_on.pick_random()
		var minute = random_shot["minute"]
		shots_on.erase(random_shot)
		
		var event = create_goal_event(home_team.team_id, player_scored.player_id, minute)
		events.append(event)
		
	for goals in away_goals:
		var shots_on = away_shots_on.duplicate()
		var player_scored = away_team.get_picked_players().filter(
			func(player):
				return player.player_position != PlayingPosition.GK
		).pick_random()
		player_scored.goals_scored += 1
		
		var random_shot = shots_on.pick_random()
		var minute = random_shot["minute"]
		shots_on.erase(random_shot)
		
		var event = create_goal_event(away_team.team_id, player_scored.player_id, minute)
		events.append(event)
	
	for player in home_team.get_picked_players() + away_team.get_picked_players():
		player.matches_played += 1
	
	return { 
		"home_team": get_division_team_id(home_team.division, home_team.team_id),
		"away_team": get_division_team_id(away_team.division, away_team.team_id),
		"home_team_goals": home_goals,
		"away_team_goals": away_goals,
		"match_events": events,
		"match_stats": stats,
		}


func assign_stats_events(team: Team, team_skill: int) -> Dictionary:
	var stats = {
		"shots": 0,
		"shots_on_target": [],
		"corners": []
	}
	# total skill
	# Determine shots based on skill and randomness
	var shots = randi_range(5, 15) + team_skill / 10
	stats["shots"] = shots
	# Convert a portion of shots to shots on target
	var shots_on_target = randi_range(1, shots / 2)
	for i in range(shots_on_target):
		var minute = randi_range(1, 90)
		var player = team.get_picked_players().pick_random()
		stats["shots_on_target"].append({"player": player, "minute": minute})
	# Simulate corners based on shots taken
	var corners = randi_range(1, shots / 3)
	for i in range(corners):
		var minute = randi_range(1, 90)
		var player = team.get_picked_players().pick_random()
		stats["corners"].append({"player": player, "minute": minute})
	return stats

func assign_bookings(team : Team) -> Dictionary:
	var yellow_cards = []
	var red_cards = []
	
	for player in team.get_picked_players():
		var random_chance = randi_range(1, 20)
		if random_chance < 1:
			red_cards.append({"player": player, "minute": randi_range(1, 90)})
		elif random_chance < 4:
			yellow_cards.append({"player": player, "minute": randi_range(1, 90)})
	for event in yellow_cards:
		var random_chance = randi_range(1, 20)
		if random_chance < 3:
			if event["minute"] >= 89:
				event["minute"] = 88;
			red_cards.append({"player": event["player"], "minute": randi_range(event["minute"] + 1, 90)})
			
	return {"yellow_cards": yellow_cards, "red_cards": red_cards }

func create_half_time_event():
	var match_event = match_event_prefab.instantiate()
	match_event.minute = 45
	match_event.event_type = MatchEngine.MatchEventType.HALF_TIME
	return match_event
	
func create_goal_event(team_id, player_scored, minute_scored):
	var match_event = match_event_prefab.instantiate()
	match_event.team_id = team_id
	match_event.player_id = player_scored
	match_event.minute = minute_scored
	match_event.event_type = MatchEngine.MatchEventType.GOAL
	return match_event
	
func create_booking_event(team_id, player_booked, minute_booked):
	var match_event = match_event_prefab.instantiate()
	match_event.team_id = team_id
	match_event.player_id = player_booked
	match_event.minute = minute_booked
	match_event.event_type = MatchEngine.MatchEventType.YELLOW_CARD
	return match_event
	
func create_sendingoff_event(team_id, player_sentoff, minute_sentoff):
	var match_event = match_event_prefab.instantiate()
	match_event.team_id = team_id
	match_event.player_id = player_sentoff
	match_event.minute = minute_sentoff
	match_event.event_type = MatchEngine.MatchEventType.RED_CARD
	return match_event
	
func create_shotontarget_event(team_id, player_id, minute):
	var match_event = match_event_prefab.instantiate()
	match_event.team_id = team_id
	match_event.player_id = player_id
	match_event.minute = minute
	match_event.event_type = MatchEngine.MatchEventType.SHOT_ON_TARGET
	return match_event
	
func create_corner_event(team_id, player_id, minute):
	var match_event = match_event_prefab.instantiate()
	match_event.team_id = team_id
	match_event.player_id = player_id
	match_event.minute = minute
	match_event.event_type = MatchEngine.MatchEventType.CORNER
	return match_event

func get_player_match(week):
	var division_id = get_player_team().division
	var team_id = get_division_team_id(division_id, get_player_team().team_id)
	var division = game_data.divisions[division_id]
	var results = division.results[week]
	var player_result = results.filter(
		func(result): 
			return result["home_team"] == team_id or result["away_team"] == team_id).front()
	return player_result

func get_results():
	var results = []
	for division in game_data.divisions:
		results.append(division.results[game_data.current_week])
	return results

func finish_week():
	var last_match = get_player_match(game_data.current_week)
	game_data.current_week += 1
	
	if (game_data.current_week >= game_data.divisions[game_data.teams[game_data.human_index].division].fixtures.size()):
		finish_season()
		return

	# Add gate receipts if home
	var player_team : Team = get_player_team()
	var fixture = get_fixture(player_team.division, player_team.team_id)
	var was_home = false
	if fixture != null:
		was_home = fixture["home_team"] == player_team.team_id
	
	var gate_receipts = FinanceEntry.new()
	gate_receipts.entry_name = "Gate Receipts"
	gate_receipts.entry_amount = 0
	if was_home:
		var attendance = last_match["match_stats"].attendance
		gate_receipts.entry_amount = attendance * player_team.avg_price
	player_team.finances.income.append([gate_receipts])
	player_team.finances.current_money += gate_receipts.entry_amount
	
	# Deduct wages
	var total_skill = player_team.get_picked_players().map(func(player): return player.player_skill).reduce(func(acc, sum): return acc + sum)
	var wages = FinanceEntry.new()
	wages.entry_name = "Wages"
	wages.entry_amount = total_skill * 500
	
	player_team.finances.expense.append([wages])
	player_team.finances.current_money -= wages.entry_amount
		
func finish_season():
	for division: Division in game_data.divisions:
		var table: Array = division.get_league_table(game_data.current_season)
		var promoted = []
		var relegated = []
		# get 2 promoted teams and relegated teams
		if division.division_id == 0:
			# no promotion in the top division
			relegated = table.slice(-2)
		elif division.division_id == game_data.divisions.size() - 1:
			promoted = table.slice(0, 2)
		else:
			promoted = table.slice(0, 2)
			relegated = table.slice(-2)
		for team in promoted:
			move_team_to_division(get_team(team), division.division_id - 1)
		for team in relegated:
			move_team_to_division(get_team(team), division.division_id + 1)
	
	for team: Team in game_data.teams:
		game_data.create_new_season_stats(team)
	
	game_data.current_season += 1
	game_data.current_week = 0
	create_fixtures()
	
	var player_team : Team = get_player_team()
	for player : Player in player_team.get_players():
		player.yellow_cards = 0
		player.goals_scored = 0
		player.matches_played = 0
	
func get_formation_name(formation):
	match formation:
		Formation.FORMATION_4_4_2:
			return "4-4-2"
		Formation.FORMATION_4_5_1:
			return "4-5-1"
		Formation.FORMATION_4_3_3:
			return "4-3-3"
		Formation.FORMATION_5_3_2:
			return "5-3-2"
	return "Unknown"
	
func get_players_by_position(position):
	var matching_position = position
	match position:
		3:
			matching_position = 4
		4:
			matching_position = 8
	return game_data.players.filter(func(player): 
		return (player.player_position & matching_position) == matching_position)
	
func bid_on_player(team, player, price):
	var bid = Bid.new()
	bid.team = team
	bid.player = player
	bid.price = price
	queued_bids.append(bid)
	old_scene = get_tree().current_scene
	get_tree().root.add_child(bid_player.instantiate())

func set_player_unavailable(player_id: int):
	var player = get_player_by_id(player_id)
	player.available = false

func buy_player(player_id, price):
	# TODO: move money from one team to another
	var human_team = get_player_team()
	if human_team.get_team_size() > max_team_size:
		return "Not enough space in squad"
	if human_team.finances.current_money < price:
		return "Not enough money"
	human_team.finances.current_money -= price
	var player = get_player_by_id(player_id)
	add_player_to_team(player, human_team)
	return "Bid was accepted"

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		for team in game_data.teams:
			for team_stats in team.season_stats:
				team_stats.queue_free()
			for week in team.finances.income:
				for income in week:
					income.queue_free()
			for week in team.finances.expense:
				for expense in week:
					expense.queue_free()
			team.finances.queue_free()
			team.queue_free()
		for player in game_data.players:
				player.queue_free()
#		for season in seasons:
#			season.queue_free()
		for division in game_data.divisions:
			for weekly_result in division.results:
				for match_result in weekly_result:
					for event in match_result["match_events"]:
						event.queue_free()
					match_result["match_stats"].queue_free()
			division.queue_free()
		for bid in queued_bids:
			bid.queue_free()
		get_tree().quit()

func save_game():
	var file_access = GameFileAccess.new()
	file_access.save_game_file("user://savefile.nl", game_data)
	file_access.queue_free()
	
func load_game():
	var file_access = GameFileAccess.new()
	game_data = file_access.load_game_file("user://savefile.nl")
	loaded_game = true
	file_access.queue_free()
	
