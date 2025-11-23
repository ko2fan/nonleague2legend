extends Control

@onready var team_container = $Panel/VBoxContainer/ScrollContainer/TeamContainer

@onready var team_picker_button_prefab = preload("res://Scenes/team_picker_button.tscn")
@onready var tiles_scene = preload("res://Scenes/tiles.tscn")

func _ready():
	var teams = GameManager.get_teams()
	var id = 0
	for team in teams:
		var button = team_picker_button_prefab.instantiate()
		button.set_button(id, team.team_name)
		button.team_picked.connect(self._team_picked)
		team_container.add_child(button)
		id += 1
		
func _team_picked(index):
	print("Player chose " + team_container.get_child(index).text)
	GameManager.set_player_index(team_container.get_child(index).text)
	var division_id = GameManager.get_player_team().division
	var teams = GameManager.get_teams()
	var team_swap = teams[GameManager.get_last_division().teams.back()]
	GameManager.move_team_to_division(team_swap, division_id)
	GameManager.move_team_to_division(GameManager.get_player_team(), 3)
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene("tiles_view")
	
func _exit_tree():
	GameManager.game_started = true
	for child in team_container.get_children():
		child.queue_free()
		team_container.remove_child(child)
