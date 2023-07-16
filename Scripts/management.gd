extends Node

@onready var ui_panel = $UI

@onready var team_picker_view = preload("res://Scenes/team_picker.tscn")

var current_scene

func _ready():
	var team_picker = team_picker_view.instantiate()
	ui_panel.add_child(team_picker)
	current_scene = team_picker

func change_to_packed_scene(scene):
	var old_scene = current_scene
	ui_panel.remove_child(old_scene)
	old_scene.queue_free()
	
	current_scene = scene.instantiate()
	ui_panel.add_child(current_scene)
	
func _exit_tree():
	current_scene.queue_free()
	ui_panel.remove_child(current_scene)
