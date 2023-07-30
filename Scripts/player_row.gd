extends Control

signal player_selected

@onready var row_colour = $ColorRect
@onready var player_button = $ColorRect/HBoxContainer/Button
@onready var squad_label = $ColorRect/HBoxContainer/SquadNumber
@onready var player_position = $ColorRect/HBoxContainer/PlayerPosition
@onready var player_skill_label = $ColorRect/HBoxContainer/PlayerSkill

var squad_number

func set_player(player_details : Player):
	squad_number = player_details.squad_number
	player_button.text = player_details.player_name
	squad_label.text = str(player_details.squad_number + 1)
	player_skill_label.text = str(player_details.player_skill)
	match player_details.player_position:
		GameManager.PlayingPosition.GK:
			player_position.text = "GK"
			player_position.tooltip_text = "Goalkeeper"
		GameManager.PlayingPosition.DEF:
			player_position.text = "DEF"
			player_position.tooltip_text = "Defender"
		GameManager.PlayingPosition.DEF + GameManager.PlayingPosition.MID:
			player_position.text = "D/M"
			player_position.tooltip_text = "Defender or Midfielder"
		GameManager.PlayingPosition.MID:
			player_position.text = "MID"
			player_position.tooltip_text = "Midfielder"
		GameManager.PlayingPosition.MID + GameManager.PlayingPosition.ATT:
			player_position.text = "M/S"
			player_position.tooltip_text = "Midfielder or Striker"
		GameManager.PlayingPosition.ATT:
			player_position.text = "STR"
			player_position.tooltip_text = "Striker"
	match squad_number:
		0:
			row_colour.color = Color.WEB_GREEN
		1,2,3,4:
			row_colour.color = Color.DEEP_SKY_BLUE
		5,6,7,8:
			row_colour.color = Color.YELLOW
		9,10:
			row_colour.color = Color.CRIMSON

func _on_button_pressed():
	player_button.button_pressed = true
	emit_signal("player_selected", squad_number)
