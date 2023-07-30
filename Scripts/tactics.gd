extends Control

@onready var tactic_grid = $Panel/Pitch/TacticGrid

@onready var grid_prefab = preload("res://Scenes/grid.tscn")
@onready var shirt_texture = preload("res://Sprites/shirt.png")
@onready var tiles_scene = preload("res://Scenes/tiles.tscn")

var formation = GameManager.Formation.FORMATION_4_4_2
var grid_system = []

func _ready():
	draw_grid()
	draw_tactic(GameManager.get_player_team().get_players())
	
func draw_grid():
	for x in 20:
		var grid_item = grid_prefab.instantiate()
		grid_system.append(grid_item)
		tactic_grid.add_child(grid_item)

func draw_tactic(players):
	match formation:
		GameManager.Formation.FORMATION_4_4_2:
			#gk
			grid_system[2].set_player(shirt_texture, players[0].player_name)
			#def
			grid_system[5].set_player(shirt_texture, players[1].player_name)
			grid_system[6].set_player(shirt_texture, players[2].player_name)
			grid_system[8].set_player(shirt_texture, players[3].player_name)
			grid_system[9].set_player(shirt_texture, players[4].player_name)
			#mid
			grid_system[10].set_player(shirt_texture, players[5].player_name)
			grid_system[11].set_player(shirt_texture, players[6].player_name)
			grid_system[13].set_player(shirt_texture, players[7].player_name)
			grid_system[14].set_player(shirt_texture, players[8].player_name)
			#att
			grid_system[16].set_player(shirt_texture, players[9].player_name)
			grid_system[18].set_player(shirt_texture, players[10].player_name)


func _on_back_button_pressed():
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene(tiles_scene)
