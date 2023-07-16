extends Control

@onready var team_container = $Panel/VBoxContainer/ScrollContainer/TeamContainer

func _ready():
	var teams = GameManager.get_teams()
	for team in teams:
		var button = Button.new()
		button.text = team.team_name
		button.pressed.connect(self._button_pressed)
		team_container.add_child(button)
		
func _button_pressed():
	pass
