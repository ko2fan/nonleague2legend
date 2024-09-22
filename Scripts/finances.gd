extends Control

@onready var income_table = $Panel/HBoxContainer/Income
@onready var expenses_table = $Panel/HBoxContainer/Expenses
@onready var cash = $Panel/CurrentMoney

@onready var tiles = preload("res://Scenes/tiles.tscn")

func _ready():
	cleanup()
	var week: int = GameManager.get_week()
	var team_finances = GameManager.get_player_team().get_finances()
	if team_finances != null:
		for income in team_finances.get_income(week):
			var income_label = Label.new()
			income_label.label_settings = load("res://Themes/finance_settings.tres")
			income_label.text = income.entry_name + ": £" + Utils.CommaNumber(income.entry_amount)
			income_table.add_child(income_label)
		for expense in team_finances.get_expense(week):
			var expense_label = Label.new()
			expense_label.label_settings = load("res://Themes/finance_settings.tres")
			expense_label.text = expense.entry_name + ": £" + Utils.CommaNumber(expense.entry_amount)
			expenses_table.add_child(expense_label)
	cash.text = "Cash: £{0}".format([Utils.CommaNumber(team_finances.current_money)])
	
func cleanup():
	for child in income_table.get_children():
		child.queue_free()
		income_table.remove_child(child)
		
	for child in expenses_table.get_children():
		child.queue_free()
		expenses_table.remove_child(child)
		



func _on_back_button_pressed():
	cleanup()
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene(tiles)
