extends Control

@onready var line_colour = $LineColour
@onready var position_label = $LineColour/HBoxContainer/Pos
@onready var team_label = $LineColour/HBoxContainer/Team
@onready var played_label = $LineColour/HBoxContainer/Played
@onready var wins_label = $LineColour/HBoxContainer/Wins
@onready var draws_label = $LineColour/HBoxContainer/Draws
@onready var losses_label = $LineColour/HBoxContainer/Losses
@onready var gf_label = $LineColour/HBoxContainer/GoalsFor
@onready var ga_label = $LineColour/HBoxContainer/GoalsAgainst
@onready var points_label = $LineColour/HBoxContainer/Points

func set_colour(colour):
	line_colour.color = colour

func set_row(league_entry):
	position_label.text = str(league_entry.position)
	team_label.text = league_entry.team_name
	played_label.text = str(league_entry.played)
	wins_label.text = str(league_entry.wins)
	draws_label.text = str(league_entry.draws)
	losses_label.text = str(league_entry.losses)
	gf_label.text = str(league_entry.gf)
	ga_label.text = str(league_entry.ga)
	points_label.text = str(league_entry.points)
