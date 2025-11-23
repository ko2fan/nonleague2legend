extends Control

@onready var title_label = $Panel/Title
@onready var week_button = %WeekButton
@onready var next_match_label = %NextMatchLabel

@onready var match_view = preload("res://Scenes/match.tscn")

func _ready():
	var player_team := GameManager.get_player_team()
	title_label.text = player_team.team_name
	week_button.text = "Week " + str(GameManager.get_week() + 1)
	var fixture = GameManager.get_fixture(player_team.division, player_team.team_id)
	if fixture != null:
		var next_match := "TEAM_ID"
		if fixture["home_team"] == player_team.team_id:
			next_match = GameManager.get_team(fixture["away_team"]).team_name
		else:
			next_match = GameManager.get_team(fixture["home_team"]).team_name 
		next_match_label.text = "Next match vs " + next_match 
	else:
		next_match_label.text = "No match this week" 

func _on_view_squad_button_pressed():
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene("squad_view")


func _on_save_game_button_pressed():
	GameManager.save_game()


func _on_next_game_button_pressed():
	get_tree().change_scene_to_packed(match_view)


func _on_league_table_button_pressed():
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene("league_view")


func _on_tactics_button_pressed():
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene("tactics_view")


func _on_scouting_button_pressed():
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene("scouting_view")


func _on_finances_button_pressed():
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene("finances_view")
