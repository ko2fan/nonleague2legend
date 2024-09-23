extends Node

class_name GameFileAccess

func save_game_file(filename: String, game_data: GameData):
	var save_file = FileAccess.open(filename, FileAccess.WRITE)
	var version = 0x13
	save_file.store_32(version)
	# GLOBALS
	save_file.store_32(game_data.human_index)
	save_file.store_32(game_data.current_season)
	save_file.store_32(game_data.current_week)
	# DIVISIONS
	save_file.store_32(game_data.divisions.size())
	for division in game_data.divisions:
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
				save_file.store_8(result["home_team_goals"])
				save_file.store_32(result["away_team"])
				save_file.store_8(result["away_team_goals"])
				# match stats
				save_file.store_32(result["match_stats"].attendance)
				save_file.store_8(result["match_stats"].home_shots_on_target)
				save_file.store_8(result["match_stats"].home_shots_off_target)
				save_file.store_8(result["match_stats"].home_possession_percent)
				save_file.store_8(result["match_stats"].home_corners)
				save_file.store_8(result["match_stats"].away_shots_on_target)
				save_file.store_8(result["match_stats"].away_shots_off_target)
				save_file.store_8(result["match_stats"].away_possession_percent)
				save_file.store_8(result["match_stats"].away_corners)
				# match events
				save_file.store_8(result["match_events"].size())
				for event in result["match_events"]:
					save_file.store_32(event.team_id)
					save_file.store_32(event.player_id)
					save_file.store_8(event.minute)
					save_file.store_32(event.event_type)
	# TEAMS
	save_file.store_32(game_data.teams.size())
	for team in game_data.teams:
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
		save_file.store_8(team.formation)
		save_file.store_32(team.finances.current_money)
		save_file.store_8(team.finances.income.size())
		for week in team.finances.income:
			save_file.store_8(week.size())
			for income in week:
				save_file.store_pascal_string(income.entry_name)
				save_file.store_32(income.entry_amount)
		save_file.store_8(team.finances.expense.size())
		for week in team.finances.expense:
			save_file.store_8(week.size())
			for expense in week:
				save_file.store_pascal_string(expense.entry_name)
				save_file.store_32(expense.entry_amount)
		save_file.store_8(team.avg_price)
	# PLAYERS
	save_file.store_32(game_data.players.size())
	for player in game_data.players:
		save_file.store_32(player.player_id)
		save_file.store_pascal_string(player.player_name)
		save_file.store_8(player.squad_number)
		save_file.store_8(player.player_position)
		save_file.store_8(player.player_skill)
		save_file.store_16(player.matches_played)
		save_file.store_16(player.goals_scored)
		save_file.store_8(player.yellow_cards)
		save_file.store_8(player.suspended)
		save_file.store_8(player.available)
		if player.team != null:
			save_file.store_32(player.team.team_id)
		else:
			save_file.store_32(4294967295)
	save_file.close()

func load_game_file(filename: String) -> GameData:
	var game_data = GameData.new()
	var load_file = FileAccess.open(filename, FileAccess.READ)
	var version = load_file.get_32()
	match version:
		0x12:
			game_data.human_index = load_file.get_32()
			game_data.current_season = load_file.get_32()
			game_data.current_week = load_file.get_32()
			var num_divisions = load_file.get_32()
			for i in num_divisions:
				var division = Division.new()
				division.division_id = load_file.get_32()
				var num_teams_in_div = load_file.get_32()
				for j in num_teams_in_div:
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
						var home_goals = load_file.get_8()
						var away_team = load_file.get_32()
						var away_goals = load_file.get_8()
						# match stats
						var stats = GameManager.match_stat_prefab.instantiate()
						stats.attendance = load_file.get_32()
						stats.home_shots_on_target = load_file.get_8()
						stats.home_shots_off_target = load_file.get_8()
						stats.home_possession_percent = load_file.get_8()
						stats.home_corners = load_file.get_8()
						stats.away_shots_on_target = load_file.get_8()
						stats.away_shots_off_target = load_file.get_8()
						stats.away_possession_percent = load_file.get_8()
						stats.away_corners = load_file.get_8()
						#match events
						var events_size = load_file.get_8()
						var events = []
						for e in events_size:
							var event = GameManager.match_event_prefab.instantiate()
							event.team_id = load_file.get_32()
							event.player_id = load_file.get_32()
							event.minute = load_file.get_8()
							event.event_type = load_file.get_32()
							events.append(event)
						var result = { "home_team": home_team,
									"away_team": away_team,
									"home_team_goals": home_goals,
									"away_team_goals": away_goals,
									"match_events": events,
									"match_stats": stats }
						weekly_results.append(result)
					division.results.append(weekly_results)
				game_data.divisions.append(division)
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
				team.formation = load_file.get_8()
				team.finances = TeamFinances.new()
				team.finances.current_money = load_file.get_32()
				var num_income_weeks = load_file.get_8()
				for week in num_income_weeks:
					var week_income = []
					var num_income = load_file.get_8()
					for income in num_income:
						var entry = FinanceEntry.new()
						entry.entry_name = load_file.get_pascal_string()
						entry.entry_amount = load_file.get_32()
						week_income.append(entry)
					team.finances.income.append(week_income)
				var num_expense_weeks = load_file.get_8()
				for week in num_expense_weeks:
					var week_expense = []
					var num_expense = load_file.get_8()
					for expense in num_expense:
						var entry = FinanceEntry.new()
						entry.entry_name = load_file.get_pascal_string()
						entry.entry_amount = load_file.get_32()
						week_expense.append(entry)
					team.finances.expense.append(week_expense)
				team.avg_price = load_file.get_8()
				game_data.teams.append(team)
			var num_players = load_file.get_32()
			for i in num_players:
				var player = Player.new()
				player.player_id = load_file.get_32()
				player.player_name = load_file.get_pascal_string()
				player.squad_number = load_file.get_8()
				player.player_position = load_file.get_8()
				player.player_skill = load_file.get_8()
				player.matches_played = load_file.get_16()
				player.goals_scored = load_file.get_16()
				player.yellow_cards = load_file.get_8()
				player.suspended = load_file.get_8()
				player.available = true
				var team_id = load_file.get_32()
				if team_id != 4294967295:
					var player_team = game_data.teams.filter(func(team): return team.team_id == team_id).front()
					player_team.players.append(player)
					player.team = player_team
				game_data.players.append(player)
		0x13:
			game_data.human_index = load_file.get_32()
			game_data.current_season = load_file.get_32()
			game_data.current_week = load_file.get_32()
			var num_divisions = load_file.get_32()
			for i in num_divisions:
				var division = Division.new()
				division.division_id = load_file.get_32()
				var num_teams_in_div = load_file.get_32()
				for j in num_teams_in_div:
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
						var home_goals = load_file.get_8()
						var away_team = load_file.get_32()
						var away_goals = load_file.get_8()
						# match stats
						var stats = GameManager.match_stat_prefab.instantiate()
						stats.attendance = load_file.get_32()
						stats.home_shots_on_target = load_file.get_8()
						stats.home_shots_off_target = load_file.get_8()
						stats.home_possession_percent = load_file.get_8()
						stats.home_corners = load_file.get_8()
						stats.away_shots_on_target = load_file.get_8()
						stats.away_shots_off_target = load_file.get_8()
						stats.away_possession_percent = load_file.get_8()
						stats.away_corners = load_file.get_8()
						#match events
						var events_size = load_file.get_8()
						var events = []
						for e in events_size:
							var event = GameManager.match_event_prefab.instantiate()
							event.team_id = load_file.get_32()
							event.player_id = load_file.get_32()
							event.minute = load_file.get_8()
							event.event_type = load_file.get_32()
							events.append(event)
						var result = { "home_team": home_team,
									"away_team": away_team,
									"home_team_goals": home_goals,
									"away_team_goals": away_goals,
									"match_events": events,
									"match_stats": stats }
						weekly_results.append(result)
					division.results.append(weekly_results)
				game_data.divisions.append(division)
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
				team.formation = load_file.get_8()
				team.finances = TeamFinances.new()
				team.finances.current_money = load_file.get_32()
				var num_income_weeks = load_file.get_8()
				for week in num_income_weeks:
					var week_income = []
					var num_income = load_file.get_8()
					for income in num_income:
						var entry = FinanceEntry.new()
						entry.entry_name = load_file.get_pascal_string()
						entry.entry_amount = load_file.get_32()
						week_income.append(entry)
					team.finances.income.append(week_income)
				var num_expense_weeks = load_file.get_8()
				for week in num_expense_weeks:
					var week_expense = []
					var num_expense = load_file.get_8()
					for expense in num_expense:
						var entry = FinanceEntry.new()
						entry.entry_name = load_file.get_pascal_string()
						entry.entry_amount = load_file.get_32()
						week_expense.append(entry)
					team.finances.expense.append(week_expense)
				team.avg_price = load_file.get_8()
				game_data.teams.append(team)
			var num_players = load_file.get_32()
			for i in num_players:
				var player = Player.new()
				player.player_id = load_file.get_32()
				player.player_name = load_file.get_pascal_string()
				player.squad_number = load_file.get_8()
				player.player_position = load_file.get_8()
				player.player_skill = load_file.get_8()
				player.matches_played = load_file.get_16()
				player.goals_scored = load_file.get_16()
				player.yellow_cards = load_file.get_8()
				player.suspended = load_file.get_8()
				player.available = load_file.get_8()
				var team_id = load_file.get_32()
				if team_id != 4294967295:
					var player_team = game_data.teams.filter(func(team): return team.team_id == team_id).front()
					player_team.players.append(player)
					player.team = player_team
				game_data.players.append(player)
	load_file.close()
	
	return game_data
