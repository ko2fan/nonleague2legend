extends Control

@onready var scrolled_container = $Panel/ScrollContainer
@onready var scouted_player_container = $Panel/ScrollContainer/VBoxContainer

@onready var scout_row = preload("res://Scenes/scout_row.tscn")
@onready var tiles_scene = preload("res://Scenes/tiles.tscn")

var scout_position

func cleanup():
	for child in scouted_player_container.get_children():
		child.queue_free()
		scouted_player_container.remove_child(child)
		
func _on_return_button_pressed():
	cleanup()
		
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene(tiles_scene)

func _on_scout_button_pressed():
	scrolled_container.show()
	var players = GameManager.get_players_by_position(scout_position)
	show_players(players)

func _on_scout_position_item_selected(index):
	scout_position = index

func show_players(players):
	cleanup()
		
	for player in players:
		var player_row = scout_row.instantiate()
		scouted_player_container.add_child(player_row)
		player_row.set_player_row(player)
