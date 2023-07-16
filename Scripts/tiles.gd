extends Control

@onready var title_label = $Panel/Title

func _ready():
	title_label.text = GameManager.get_player_team().team_name
