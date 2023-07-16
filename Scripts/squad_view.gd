extends Control

@onready var player_container = $Panel/ScrollContainer/PlayerContainer

@onready var player_row_prefab = preload("res://Scenes/player_row.tscn")
@onready var tiles_scene = preload("res://Scenes/tiles.tscn")

func _ready():
	var players = GameManager.get_player_team().get_players()
	for player in players:
		var player_row = player_row_prefab.instantiate()
		player_row.set_player(player)
		player_container.add_child(player_row)

func _exit_tree():
	for child in player_container.get_children():
		child.queue_free()
		player_container.remove_child(child)


func _on_back_button_pressed():
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene(tiles_scene)
