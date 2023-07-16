extends Control

@onready var management_ui = preload("res://Scenes/management.tscn")

func _on_new_game_button_pressed():
	GameManager.create_profile()
	get_tree().change_scene_to_packed(management_ui)


func _on_save_game_button_pressed():
	pass # Replace with function body.


func _on_load_game_button_pressed():
	pass # Replace with function body.


func _on_quit_game_button_pressed():
	get_tree().quit()
