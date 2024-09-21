extends Control

signal player_selected
signal sell_player

@onready var row_colour = $ColorRect
@onready var player_button: Button = $ColorRect/HBoxContainer/Button
@onready var squad_label: Label = $ColorRect/HBoxContainer/SquadNumber
@onready var player_position: Label = $ColorRect/HBoxContainer/PlayerPosition
@onready var player_skill_label: Label = $ColorRect/HBoxContainer/PlayerSkill
@onready var played: Label = $ColorRect/HBoxContainer/Played
@onready var scored: Label = $ColorRect/HBoxContainer/Scored
@onready var yellows: Label = $ColorRect/HBoxContainer/Yellows

var squad_number

func set_player(player_details : Player, formation):
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
	match formation:
		GameManager.Formation.FORMATION_4_4_2:
			change_colour(1, 4, 4, 2)
		GameManager.Formation.FORMATION_4_5_1:
			change_colour(1, 4, 5, 1)
		GameManager.Formation.FORMATION_4_3_3:
			change_colour(1, 4, 3, 3)
		GameManager.Formation.FORMATION_5_3_2:
			change_colour(1, 5, 3, 2)
	played.text = str(player_details.matches_played)
	scored.text = str(player_details.goals_scored)
	yellows.text = str(player_details.yellow_cards)
	if player_details.suspended >= 1:
		row_colour.color = Color.WEB_PURPLE
	
func change_colour(gk, def, mid, att):
	if squad_number < gk:
		row_colour.color = GameManager.positional_colour["GK"]
	elif squad_number <= def:
			row_colour.color = GameManager.positional_colour["DEF"]
	elif squad_number <= def + mid:
		row_colour.color = GameManager.positional_colour["MID"]
	elif squad_number <= def + mid + att:
		row_colour.color = GameManager.positional_colour["ATT"]

func _on_button_pressed():
	player_button.button_pressed = true
	emit_signal("player_selected", squad_number)


func _on_sell_button_pressed():
	emit_signal("sell_player", squad_number)
