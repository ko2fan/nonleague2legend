extends Control

@onready var player_container = $Panel/ScrollContainer/PlayerContainer
@onready var error_label = $Panel/ErrorMessage

@onready var player_row_prefab = preload("res://Scenes/player_row.tscn")
@onready var tiles_scene = preload("res://Scenes/tiles.tscn")

var selected_player = -1

var human_team : Team

func _ready():
	error_label.hide()
	human_team = GameManager.get_player_team()
	draw_players()

func cleanup():
	for child in player_container.get_children():
		child.queue_free()
		player_container.remove_child(child)

func draw_players():
	cleanup()
	human_team.sort_players()

	var players = human_team.get_players()
	for player in players:
		var player_row = player_row_prefab.instantiate()
		player_row.player_selected.connect(_on_player_selected)
		player_row.sell_player.connect(_on_sell_player)
		player_container.add_child(player_row)
		await get_tree().process_frame
		player_row.set_player(player, human_team.formation)

func _exit_tree():
	cleanup()

func _on_back_button_pressed():
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene(tiles_scene)
	
func _on_player_selected(player_index):
	if selected_player == -1:
		selected_player = player_index
	else:
		human_team.switch_players(selected_player, player_index)
		selected_player = -1
		draw_players()

func _on_sell_player(player_index):
	if human_team.players.size() < 12:
		error_label.text = "Not enough players"
		error_label.show()
		return
	var sell_price = (human_team.get_player(player_index).player_skill - 1) * 100000
	human_team.sell_player(player_index, sell_price)
	draw_players()
