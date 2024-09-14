extends Node2D

@onready var menu = preload("res://Scenes/menu.tscn")

func _ready():
	get_tree().call_deferred("change_scene_to_packed", menu)
