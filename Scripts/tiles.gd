extends Control

@onready var title_label = $Panel/Title
@onready var week_button = $Panel/GridContainer/WeekButton

@onready var squad_view = preload("res://Scenes/squad_view.tscn")
@onready var match_view = preload("res://Scenes/match.tscn")
@onready var league_view = preload("res://Scenes/league_view.tscn")
@onready var tactics_view = preload("res://Scenes/tactics.tscn")
@onready var scouting_view = preload("res://Scenes/scout_view.tscn")
@onready var finances = preload("res://Scenes/finances.tscn")

func _ready():
	title_label.text = GameManager.get_player_team().team_name
	week_button.text = "Week " + str(GameManager.current_week + 1)

func _on_view_squad_button_pressed():
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene(squad_view)


func _on_save_game_button_pressed():
	GameManager.save_game()


func _on_next_game_button_pressed():
	get_tree().change_scene_to_packed(match_view)


func _on_league_table_button_pressed():
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene(league_view)


func _on_tactics_button_pressed():
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene(tactics_view)


func _on_scouting_button_pressed():
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene(scouting_view)


func _on_finances_button_pressed():
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene(finances)
