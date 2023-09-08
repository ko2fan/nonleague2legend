extends Node

class_name TeamFinances

var current_money : int
var income = []
var expense = []

func get_income(week):
	if week > income.size():
		return []
	else:
		return income[week]
		
func get_expense(week):
	if week > expense.size():
		return []
	else:
		return expense[week]
