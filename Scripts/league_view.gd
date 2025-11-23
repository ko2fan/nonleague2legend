extends Control

@onready var title = $Panel/Title
@onready var league_table = $Panel/ScrollContainer/VBoxContainer

@onready var league_row_prefab = preload("res://Scenes/league_row.tscn")

func _ready():
	cleanup()
	var season = GameManager.get_season()
	var division_id = GameManager.get_player_team().division
	var division = GameManager.get_division(division_id)
	var table = division.get_league_table(season)
	var league_position = 1
	for team_id in table:
		var row = league_row_prefab.instantiate()
		var team = GameManager.get_team(team_id)
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
		row.call_deferred("set_row", league_entry)
		if league_entry.team_name == GameManager.get_player_team().team_name:
			row.call_deferred("set_colour", Color.AQUAMARINE)
		league_table.add_child(row)
		league_position += 1
	title.text = "Division " + str(division_id + 1)

func cleanup():
	for child in league_table.get_children():
		child.queue_free()
		league_table.remove_child(child)

func _on_back_button_pressed():
	cleanup()
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene("tiles_view")
