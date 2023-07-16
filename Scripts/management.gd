extends Node

@onready var ui_panel = $UI

@onready var team_picker = preload("res://Scenes/team_picker.tscn")

func _ready():
	var tp = team_picker.instantiate()
	ui_panel.add_child(tp)
