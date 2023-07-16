extends Button
class_name Team_Picker_Button

signal team_picked

var team_index = -1

func set_button(index, team_name):
	team_index = index
	self.text = team_name

func _on_pressed():
	emit_signal("team_picked", team_index)
