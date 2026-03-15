extends Node

class_name TeamFinances

var current_money : int
var income = []
var expense = []

func get_weekly_income(week):
	if week >= income.size():
		return []
	else:
		return income[week]
		
func get_weekly_expense(week):
	if week >= expense.size():
		return []
	else:
		return expense[week]

func get_monthly_income(month):
	var monthly_income = []
	for week in range(month * 4, (1 + month) * 4):
		monthly_income.append(get_weekly_income(week))
	return monthly_income
		
func get_monthly_expense(month):
	var monthly_expense = []
	for week in range(month * 4, (1 + month) * 4):
		monthly_expense.append(get_weekly_expense(week))
	return monthly_expense
