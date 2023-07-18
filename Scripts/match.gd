extends Node2D

@onready var management_ui = preload("res://Scenes/management.tscn")

@onready var home_team_label = $UI/HBoxContainer/HomeTeamName
@onready var home_score_label = $UI/HBoxContainer/HomeTeamScore
@onready var away_team_label = $UI/HBoxContainer/AwayTeamName
@onready var away_score_label = $UI/HBoxContainer/AwayTeamScore
@onready var commentary = $UI/Commentary/VBoxContainer

@onready var minute_label = $UI/Minute
@onready var continue_button = $UI/ContinueButton
@onready var match_engine = $MatchEngine

@onready var ball_indicator = $Pitch/BallIndicator

var player_team
var opposition_team

func _ready():
	player_team = GameManager.get_player_team()
	opposition_team = GameManager.teams.pick_random()
	# TODO: fill this with fixture data
	home_team_label.text = player_team.team_name
	home_score_label.text = str(0)
	away_team_label.text = opposition_team.team_name
	away_score_label.text = str(0)
	
	minute_label.text = str(0)
	continue_button.hide()
	
	match_engine.set_match(player_team, opposition_team)
	match_engine.minute_tick.connect(_on_minute_tick)
	match_engine.match_ended.connect(_on_match_ended)
	match_engine.possession_changed.connect(_on_possession_changed)
	
	for child in commentary.get_children():
		child.queue_free()
		commentary.remove_child(child)

func _on_minute_tick(minute):
	minute_label.text = str(minute)

func _on_match_ended():
	continue_button.show()

func _on_possession_changed(team_possession):
	var possession_label = Label.new()
	if team_possession == 0:
		#home team
		ball_indicator.offset = Vector2(-128, 0)
		possession_label.text = player_team.team_name + " got possession"
	else:
		#away team
		ball_indicator.offset = Vector2(128, 0)
		possession_label.text = opposition_team.team_name + " got possession"
	commentary.add_child(possession_label)

func _on_continue_button_pressed():
	get_tree().change_scene_to_packed(management_ui)
