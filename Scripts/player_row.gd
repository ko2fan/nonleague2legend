extends Control

func set_player(player_details):
	$HBoxContainer/Button.text = player_details.player_name
	$HBoxContainer/SquadNumber.text = str(player_details.squad_number + 1)
