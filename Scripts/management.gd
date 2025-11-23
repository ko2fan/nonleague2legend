extends Node

@onready var ui_panel = $UI

var current_scene

func _ready():
	if GameManager.loaded_game or GameManager.game_started:
		change_to_packed_scene("tiles_view")
	else:
		change_to_packed_scene("team_picker_view")

func change_to_packed_scene(scene):
	if current_scene != null:
		var old_scene = current_scene
		ui_panel.remove_child(old_scene)
		old_scene.queue_free()
	
	current_scene = GameManager.get_scene(scene).instantiate()
	ui_panel.add_child(current_scene)
	
func _exit_tree():
	current_scene.queue_free()
	ui_panel.remove_child(current_scene)
