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
	error_label.hide()
	for child in player_container.get_children():
		child.queue_free()
		player_container.remove_child(child)

func draw_players():
	cleanup()
	human_team.sort_players()

	var players: Array = human_team.get_players()
	for player: Player in players:
		var player_row = player_row_prefab.instantiate()
		player_row.player_selected.connect(_on_player_selected)
		player_row.sell_player.connect(_on_sell_player)
		player_container.add_child(player_row)
		await get_tree().process_frame
		player_row.set_player(player, human_team.formation)
	match human_team.formation:
		GameManager.Formation.FORMATION_4_4_2:
			# check for 1 GK, 4 DEF, 4 MID, 2 STR
			check_position(1, 4, 4, 2)
		GameManager.Formation.FORMATION_4_5_1:
			# check for 1 GK, 4 DEF, 5 MID, 1 STR
			check_position(1, 4, 5, 1)
		GameManager.Formation.FORMATION_4_3_3:
			# check for 1 GK, 4 DEF, 3 MID, 3 STR
			check_position(1, 4, 3, 3)
		GameManager.Formation.FORMATION_5_3_2:
			# check for 1 GK, 5 DEF, 3 MID, 2 STR
			check_position(1, 5, 3, 2)

func check_position(gks: int, defs: int, mids: int, atts: int):
	var num_gk = 0
	var num_def = 0
	var num_mid = 0
	var num_str = 0
	for player in human_team.get_picked_players():
		match player.player_position:
			GameManager.PlayingPosition.GK:
				num_gk += 1
			GameManager.PlayingPosition.DEF:
				num_def += 1
			GameManager.PlayingPosition.DEF + GameManager.PlayingPosition.MID:
				num_def += 1
				num_mid += 1
			GameManager.PlayingPosition.MID:
				num_mid += 1
			GameManager.PlayingPosition.MID + GameManager.PlayingPosition.ATT:
				num_mid += 1
				num_str += 1
			GameManager.PlayingPosition.ATT:
				num_str += 1
		if player.suspended >= 1:
			error_label.text = "Suspended player picked"
			error_label.show()
			return
	if num_gk != gks:
		error_label.text = "Wrong number of goalkeepers"
		error_label.show()
		return
	if num_def < defs:
		error_label.text = "Wrong number of defenders"
		error_label.show()
		return
	if num_mid < mids:
		error_label.text = "Wrong number of midfielders"
		error_label.show()
		return
	if num_str < atts:
		error_label.text = "Wrong number of strikers"
		error_label.show()
		return

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
	var num_players = human_team.players.filter(func(player): return player.suspended == 0).size()
	if num_players < 12:
		error_label.text = "Not enough eligible players"
		error_label.show()
		return
	var sell_price = (human_team.get_player(player_index).player_skill - 1) * 100000
	human_team.sell_player(player_index, sell_price)
	draw_players()
