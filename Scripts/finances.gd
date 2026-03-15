extends Control

@onready var income_table = $Panel/HBoxContainer/Income
@onready var expenses_table = $Panel/HBoxContainer/Expenses
@onready var cash = $Panel/CurrentMoney

@onready var week_label = $Panel/WeekOrMonth
@onready var last_week_button = $Panel/LastWeek
@onready var last_month_button = $Panel/LastMonth

var last_week := false
var last_month := false

func _ready():
	var week: int = GameManager.get_week()
	var month: int = GameManager.get_month()
	if week == 0:
		last_week_button.disabled = true
	if month == 0:
		last_month_button.disabled = true
		
	show_week_finances(week)
	
	cash.text = "Cash: £{0}".format([Utils.CommaNumber(GameManager.get_player_team().get_finances().current_money)])
	
func cleanup():
	for child in income_table.get_children():
		child.queue_free()
		income_table.remove_child(child)
		
	for child in expenses_table.get_children():
		child.queue_free()
		expenses_table.remove_child(child)
		

func show_week_finances(week):
	cleanup()
	week_label.text = "Week " + str(week + 1)
	var team_finances = GameManager.get_player_team().get_finances()
	if team_finances != null:
		for income in team_finances.get_weekly_income(week):
			var income_label = Label.new()
			income_label.label_settings = load("res://Themes/finance_settings.tres")
			income_label.text = income.entry_name + ": £" + Utils.CommaNumber(income.entry_amount)
			income_table.add_child(income_label)
		for expense in team_finances.get_weekly_expense(week):
			var expense_label = Label.new()
			expense_label.label_settings = load("res://Themes/finance_settings.tres")
			expense_label.text = expense.entry_name + ": £" + Utils.CommaNumber(expense.entry_amount)
			expenses_table.add_child(expense_label)
			
func show_month_finances(month):
	cleanup()
	week_label.text = "Month " + str(month + 1)
	var team_finances = GameManager.get_player_team().get_finances()
	if team_finances != null:
		for weekly_income in team_finances.get_monthly_income(month):
			for income in weekly_income:
				var income_label = Label.new()
				income_label.label_settings = load("res://Themes/finance_settings.tres")
				income_label.text = income.entry_name + ": £" + Utils.CommaNumber(income.entry_amount)
				income_table.add_child(income_label)
		for weekly_expense in team_finances.get_monthly_expense(month):
			for expense in weekly_expense:
				var expense_label = Label.new()
				expense_label.label_settings = load("res://Themes/finance_settings.tres")
				expense_label.text = expense.entry_name + ": £" + Utils.CommaNumber(expense.entry_amount)
				expenses_table.add_child(expense_label)

func _on_back_button_pressed():
	cleanup()
	var child = get_tree().root.get_node("Management")
	child.change_to_packed_scene("tiles_view")

func _on_last_week_pressed() -> void:
	if last_week == false:
		show_week_finances(GameManager.get_week() - 1)
		last_week_button.text = "This week"
		last_week = true
	else:
		show_week_finances(GameManager.get_week())
		last_week_button.text = "Last week"
		last_week = false

func _on_last_month_pressed() -> void:
	if last_month == false:
		show_month_finances(GameManager.get_month() - 1)
		last_month_button.text = "This month"
		last_month = true
	else:
		show_month_finances(GameManager.get_month())
		last_month_button.text = "Last month"
		last_month = false
