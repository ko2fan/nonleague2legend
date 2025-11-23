extends Control

@onready var tactic_grid = $Panel/Pitch/TacticGrid
@onready var formation_list = $Panel/FormationList

@onready var grid_prefab = preload("res://Scenes/grid.tscn")
@onready var shirt_texture = preload("res://Sprites/shirt.png")

var human_team
var formation = GameManager.Formation.FORMATION_4_4_2
var grid_system = []

func _ready():
	human_team = GameManager.get_player_team()
	formation = human_team.formation
	populate_list()
	draw_grid()
	draw_tactic()
	
func populate_list():
	formation_list.clear()
	
	for i in GameManager.Formation.size():
		formation_list.add_item(GameManager.get_formation_name(i))
		if i == human_team.formation:
			formation_list.select(i)
	
func draw_grid():
	for x in 20:
		var grid_item = grid_prefab.instantiate()
		grid_system.append(grid_item)
		tactic_grid.add_child(grid_item)

func clear_grid():
	for x in 20:
		grid_system[x].clear_player()

func draw_tactic():
	var players = human_team.get_players()
	
	clear_grid()
	
	match formation:
		GameManager.Formation.FORMATION_4_4_2:
			#gk
			grid_system[2].set_player(shirt_texture, players[0].player_name, GameManager.positional_colour["GK"])
			#def
			grid_system[5].set_player(shirt_texture, players[1].player_name, GameManager.positional_colour["DEF"])
			grid_system[6].set_player(shirt_texture, players[2].player_name, GameManager.positional_colour["DEF"])
			grid_system[8].set_player(shirt_texture, players[3].player_name, GameManager.positional_colour["DEF"])
			grid_system[9].set_player(shirt_texture, players[4].player_name, GameManager.positional_colour["DEF"])
			#mid
			grid_system[10].set_player(shirt_texture, players[5].player_name, GameManager.positional_colour["MID"])
			grid_system[11].set_player(shirt_texture, players[6].player_name, GameManager.positional_colour["MID"])
			grid_system[13].set_player(shirt_texture, players[7].player_name, GameManager.positional_colour["MID"])
			grid_system[14].set_player(shirt_texture, players[8].player_name, GameManager.positional_colour["MID"])
			#att
			grid_system[16].set_player(shirt_texture, players[9].player_name, GameManager.positional_colour["ATT"])
			grid_system[18].set_player(shirt_texture, players[10].player_name, GameManager.positional_colour["ATT"])
		GameManager.Formation.FORMATION_4_5_1:
			#gk
			grid_system[2].set_player(shirt_texture, players[0].player_name, GameManager.positional_colour["GK"])
			#def
			grid_system[5].set_player(shirt_texture, players[1].player_name, GameManager.positional_colour["DEF"])
			grid_system[6].set_player(shirt_texture, players[2].player_name, GameManager.positional_colour["DEF"])
			grid_system[8].set_player(shirt_texture, players[3].player_name, GameManager.positional_colour["DEF"])
			grid_system[9].set_player(shirt_texture, players[4].player_name, GameManager.positional_colour["DEF"])
			#mid
			grid_system[10].set_player(shirt_texture, players[5].player_name, GameManager.positional_colour["MID"])
			grid_system[11].set_player(shirt_texture, players[6].player_name, GameManager.positional_colour["MID"])
			grid_system[12].set_player(shirt_texture, players[7].player_name, GameManager.positional_colour["MID"])
			grid_system[13].set_player(shirt_texture, players[8].player_name, GameManager.positional_colour["MID"])
			grid_system[14].set_player(shirt_texture, players[9].player_name, GameManager.positional_colour["MID"])
			#att
			grid_system[17].set_player(shirt_texture, players[10].player_name, GameManager.positional_colour["ATT"])
		GameManager.Formation.FORMATION_4_3_3:
			#gk
			grid_system[2].set_player(shirt_texture, players[0].player_name, GameManager.positional_colour["GK"])
			#def
			grid_system[5].set_player(shirt_texture, players[1].player_name, GameManager.positional_colour["DEF"])
			grid_system[6].set_player(shirt_texture, players[2].player_name, GameManager.positional_colour["DEF"])
			grid_system[8].set_player(shirt_texture, players[3].player_name, GameManager.positional_colour["DEF"])
			grid_system[9].set_player(shirt_texture, players[4].player_name, GameManager.positional_colour["DEF"])
			#mid
			grid_system[11].set_player(shirt_texture, players[5].player_name, GameManager.positional_colour["MID"])
			grid_system[12].set_player(shirt_texture, players[6].player_name, GameManager.positional_colour["MID"])
			grid_system[13].set_player(shirt_texture, players[7].player_name, GameManager.positional_colour["MID"])
			#att
			grid_system[16].set_player(shirt_texture, players[8].player_name, GameManager.positional_colour["ATT"])
			grid_system[17].set_player(shirt_texture, players[9].player_name, GameManager.positional_colour["ATT"])
			grid_system[18].set_player(shirt_texture, players[10].player_name, GameManager.positional_colour["ATT"])
		GameManager.Formation.FORMATION_5_3_2:
			#gk
			grid_system[2].set_player(shirt_texture, players[0].player_name, GameManager.positional_colour["GK"])
			#def
			grid_system[5].set_player(shirt_texture, players[1].player_name, GameManager.positional_colour["DEF"])
			grid_system[6].set_player(shirt_texture, players[2].player_name, GameManager.positional_colour["DEF"])
			grid_system[7].set_player(shirt_texture, players[3].player_name, GameManager.positional_colour["DEF"])
			grid_system[8].set_player(shirt_texture, players[4].player_name, GameManager.positional_colour["DEF"])
			grid_system[9].set_player(shirt_texture, players[5].player_name, GameManager.positional_colour["DEF"])
			#mid
			grid_system[11].set_player(shirt_texture, players[6].player_name, GameManager.positional_colour["MID"])
			grid_system[12].set_player(shirt_texture, players[7].player_name, GameManager.positional_colour["MID"])
			grid_system[13].set_player(shirt_texture, players[8].player_name, GameManager.positional_colour["MID"])
			#att
			grid_system[16].set_player(shirt_texture, players[9].player_name, GameManager.positional_colour["ATT"])
			grid_system[18].set_player(shirt_texture, players[10].player_name, GameManager.positional_colour["ATT"])

func _on_back_button_pressed():
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene("tiles_view")


func _on_formation_list_item_selected(index):
	print("Change tactic")
	formation = index
	human_team.formation = formation
	draw_tactic()
