extends Control

@onready var league_row: Control = $Panel/VBoxContainer/LeagueRow
@onready var result_container: VBoxContainer = $Panel/VBoxContainer/ScrollContainer/ResultContainer
@onready var top_scorer_label: Label = $Panel/VBoxContainer/TopScorer
@onready var finish_week_button: Button = $Panel/FinishWeekButton

@onready var management_ui = preload("res://Scenes/management.tscn")


func _ready() -> void:
	var season = GameManager.get_season()
	var team = GameManager.get_player_team()
	# Show where in the table you finished and if you were promoted or relegated
	var division : Division = GameManager.get_division(team.division)
	var table : Array = division.get_league_table(season)
	var league_position = table.find(team.team_id) + 1
	var stats = team.season_stats[season] as TeamStats
	var league_entry = LeagueEntry.new()
	league_entry.position = league_position
	league_entry.team_name = team.team_name
	league_entry.played = stats.played
	league_entry.wins = stats.wins
	league_entry.draws = stats.draws
	league_entry.losses = stats.played - (stats.wins + stats.draws)
	league_entry.gf = stats.goals_scored
	league_entry.ga = stats.goals_conceded
	league_entry.points = (stats.wins * 3) + stats.draws
	league_row.call_deferred("set_row", league_entry)

	# Show top scorer
	var max_goals := 0
	var top_scorer : Player
	var players = team.get_players()
	for player in players:
		if player.goals_scored > max_goals:
			max_goals = player.goals_scored
			top_scorer = player
	top_scorer_label.text = "Top Scorer: " + top_scorer.player_name + " " + str(top_scorer.goals_scored)
	
	# Show results for the season
	var results = division.get_results_for_team(team.team_id)
	var div = division.division_id
	for result in results:
		var home_team = GameManager.get_team_in_division(div, result["home_team"])
		var home_score = result["home_team_goals"]
		var away_team = GameManager.get_team_in_division(div, result["away_team"])
		var away_score = result["away_team_goals"]
		
		var result_label = Label.new()
		result_label.text = home_team.team_name + " " + str(home_score) + \
			" v " + str(away_score) + " " + away_team.team_name
		result_container.add_child(result_label)
	pass


func _on_finish_week_button_pressed() -> void:
	GameManager.finish_season()
	get_tree().change_scene_to_packed(management_ui)

func _exit_tree():
	for child in result_container.get_children():
		child.queue_free()
		result_container.remove_child(child)
