extends Node2D

@onready var menu = preload("res://Scenes/menu.tscn")

func _ready():
	get_tree().change_scene_to_packed(menu)
