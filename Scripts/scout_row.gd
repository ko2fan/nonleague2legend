extends HBoxContainer

@onready var player_name = $PlayerName
@onready var player_position = $Position
@onready var player_cost = $Cost

signal player_purchased

func set_player_row(player : Player):
	player_name.text = player.player_name
	match player.player_position:
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
	player_cost.text = str(player.player_skill * 100) + "K"
