extends Control

@onready var result_container = $Panel/ScrollContainer/ResultContainer

@onready var management_ui = preload("res://Scenes/management.tscn")

func _ready():
	var results = GameManager.get_results()
	var div = 0
	for division in results:
		var division_label = Label.new()
		division_label.text = "Division " + str(div + 1)
		result_container.add_spacer(false)
		result_container.add_child(division_label)
		for result in division:
			var home_team = GameManager.get_team_in_division(div, result["home_team"])
			var home_score = result["home_team_goals"]
			var away_team = GameManager.get_team_in_division(div, result["away_team"])
			var away_score = result["away_team_goals"]
			
			var result_label = Label.new()
			result_label.text = home_team.team_name + " " + str(home_score) + \
				" v " + str(away_score) + " " + away_team.team_name
			result_container.add_child(result_label)
		div += 1
		
func _exit_tree():
	for child in result_container.get_children():
		child.queue_free()
		result_container.remove_child(child)


func _on_finish_week_button_pressed():
	GameManager.finish_week()
