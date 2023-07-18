extends Control

@onready var title_label = $Panel/Title

@onready var squad_view = preload("res://Scenes/squad_view.tscn")
@onready var match_view = preload("res://Scenes/match.tscn")

func _ready():
	title_label.text = GameManager.get_player_team().team_name

func _on_view_squad_button_pressed():
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene(squad_view)


func _on_save_game_button_pressed():
	GameManager.save_game()


func _on_next_game_button_pressed():
	get_tree().change_scene_to_packed(match_view)
