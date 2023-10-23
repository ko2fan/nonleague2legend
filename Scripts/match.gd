extends Node2D

@onready var results_view = preload("res://Scenes/results.tscn")

@onready var home_team_label = $UI/HBoxContainer/HomeTeamName
@onready var home_score_label = $UI/HBoxContainer/HomeTeamScore
@onready var away_team_label = $UI/HBoxContainer/AwayTeamName
@onready var away_score_label = $UI/HBoxContainer/AwayTeamScore
@onready var commentary = $UI/Commentary/VBoxContainer

@onready var minute_label = $UI/Minute
@onready var continue_button = $UI/ContinueButton
@onready var match_engine : MatchEngine = $MatchEngine

@onready var ball_indicator = $Pitch/BallIndicator
@onready var ball_sprite = $Pitch/Ball

var player_team
var opposition_team

var home_team
var away_team

func _ready():
	GameManager.play_matches()
	player_team = GameManager.get_player_team()
	var player_id = GameManager.get_division_team_id(player_team.division, player_team.team_id)
	var fixture = GameManager.get_fixture(player_team.division, player_id)
	
	var opposition_id = fixture["away_team"] if fixture["home_team"] == player_id \
		else fixture["home_team"]
	opposition_team = GameManager.get_team_in_division(player_team.division, opposition_id)
	
	home_team = player_team if fixture["home_team"] == player_id else opposition_team
	away_team = player_team if fixture["away_team"] == player_id else opposition_team
	
	home_team_label.text = home_team.team_name
	home_score_label.text = str(0)
	away_team_label.text = away_team.team_name
	away_score_label.text = str(0)
	
	minute_label.text = str(0)
	continue_button.hide()
	
	var match_events = GameManager.get_player_match(GameManager.current_week)
	match_engine.set_match(home_team.team_id, away_team.team_id, match_events)
	# bind to the match engine signals
	match_engine.match_event.connect(_on_match_event)
	match_engine.minute_tick.connect(_on_minute_tick)
	match_engine.match_ended.connect(_on_match_ended)
	match_engine.possession_changed.connect(_on_possession_changed)
	match_engine.ball_position_changed.connect(_on_ball_position_changed)
	
	cleanup()

func _on_minute_tick(minute):
	minute_label.text = str(minute)

func _on_match_ended():
	continue_button.show()

func _on_match_event(match_event : MatchEngine.MatchEvent):
	var match_event_label = Label.new()
	match match_event:
		MatchEngine.MatchEvent.GOAL:
			match_event_label.text = "GOAL!!!"
			home_score_label.text = str(match_engine.current_home_goals)
			away_score_label.text = str(match_engine.current_away_goals)
		MatchEngine.MatchEvent.HALF_TIME:
			match_event_label.text = "Half Time"
	commentary.add_child(match_event_label)
	
func _on_possession_changed(team_possession):
	var possession_label = Label.new()
	if team_possession == 0:
		#home team
		ball_indicator.offset = Vector2(-128, 0)
		possession_label.text = home_team.team_name + " got possession"
	else:
		#away team
		ball_indicator.offset = Vector2(128, 0)
		possession_label.text = away_team.team_name + " got possession"
	commentary.add_child(possession_label)
	
func _on_ball_position_changed(ball_position):
	ball_sprite.position = Vector2(ball_position * (26), 0)
	#print("Ball moved to " + str(ball_position))

func _on_continue_button_pressed():
	cleanup()
	get_tree().change_scene_to_packed(results_view)

func cleanup():
	for child in commentary.get_children():
		child.queue_free()
		commentary.remove_child(child)
