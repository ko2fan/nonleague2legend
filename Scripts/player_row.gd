extends Control

signal player_selected

var squad_number

func set_player(player_details):
	squad_number = player_details.squad_number
	$HBoxContainer/Button.text = player_details.player_name
	$HBoxContainer/SquadNumber.text = str(player_details.squad_number + 1)

func _on_button_pressed():
	$HBoxContainer/Button.button_pressed = true
	emit_signal("player_selected", squad_number)
