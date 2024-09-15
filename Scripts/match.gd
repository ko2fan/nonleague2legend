extends Node2D

@onready var results_view = preload("res://Scenes/results.tscn")

@onready var home_team_label = $UI/HBoxContainer/HomeTeamName
@onready var home_score_label = $UI/HBoxContainer/HomeTeamScore
@onready var away_team_label = $UI/HBoxContainer/AwayTeamName
@onready var away_score_label = $UI/HBoxContainer/AwayTeamScore
@onready var commentary = $UI/Commentary/VBoxContainer

@onready var home_stats = %MatchStats/HomeStats
@onready var away_stats = %MatchStats/AwayStats
@onready var match_stats_attendance = %MatchStats/Attendance
@onready var match_stats_home_shotson = %MatchStats/HomeShotsOnTarget
@onready var match_stats_away_shotson = %MatchStats/AwayShotsOnTarget
@onready var match_stats_home_corners = %MatchStats/HomeCorners
@onready var match_stats_away_corners = %MatchStats/AwayCorners

@onready var minute_label = $UI/Minute
@onready var continue_button = $UI/ContinueButton
@onready var match_engine : MatchEngine = $MatchEngine

@onready var ball_indicator = $Pitch/BallIndicator
@onready var ball_sprite = $Pitch/Ball

var home_team
var away_team

func _ready():
	GameManager.play_matches()
	var player_team = GameManager.get_player_team()
	var fixture = GameManager.get_fixture(player_team.division, player_team.team_id)
	
	home_team = GameManager.get_team(fixture["home_team"])
	away_team = GameManager.get_team(fixture["away_team"])
	
	home_team_label.text = home_team.team_name
	home_score_label.text = str(0)
	away_team_label.text = away_team.team_name
	away_score_label.text = str(0)
	
	home_stats.text = home_team.team_name
	away_stats.text = away_team.team_name
	
	match_stats_home_shotson.text = "Shots On Target: 0"
	match_stats_away_shotson.text = "Shots On Target: 0"
	match_stats_home_corners.text = "Corners: 0"
	match_stats_away_corners.text = "Corners: 0"
	
	minute_label.text = str(0)
	continue_button.hide()
	
	var the_match = GameManager.get_player_match(GameManager.current_week)
	var match_events = the_match["match_events"]
	var match_stats = the_match["match_stats"]
	match_engine.set_match(home_team.team_id, away_team.team_id, match_events)
	match_stats_attendance.text = "Attendance: " + str(match_stats.attendance)
	
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

func _on_match_event(match_event_type : MatchEngine.MatchEventType, match_event):
	var match_event_label = Label.new()
	var team : Team = GameManager.get_team(match_event.team_id)
	var team_name = team.team_name
	match match_event_type:
		MatchEngine.MatchEventType.GOAL:
			match_event_label.text = "GOAL!!! for " + team_name
			home_score_label.text = str(match_engine.current_home_goals)
			away_score_label.text = str(match_engine.current_away_goals)
		MatchEngine.MatchEventType.HALF_TIME:
			match_event_label.text = "Half Time, the score is " + \
				str(match_engine.current_home_goals) + " - " + str(match_engine.current_away_goals)
		MatchEngine.MatchEventType.YELLOW_CARD:
			match_event_label.text = GameManager.get_player_by_id(match_event.player_id).player_name + \
				" has been booked"
		MatchEngine.MatchEventType.RED_CARD:
			match_event_label.text = GameManager.get_player_by_id(match_event.player_id).player_name + \
				" has been sent off!"
		MatchEngine.MatchEventType.SHOT_ON_TARGET:
			match_event_label.text = team_name + " had a shot on target"
			if match_event.team_id == home_team.team_id:
				match_stats_home_shotson.text = "Shots On Target: " + \
					str(match_engine.current_home_shots_on_target)
			else:
				match_stats_away_shotson.text = "Shots On Target: " + \
					str(match_engine.current_away_shots_on_target)
		MatchEngine.MatchEventType.CORNER:
			match_event_label.text = team_name + " won a corner"
			if match_event.team_id == home_team.team_id:
				match_stats_home_corners.text = "Corners: " + \
					str(match_engine.current_home_corners)
			else:
				match_stats_away_corners.text = "Corners: " + \
					str(match_engine.current_away_corners)
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
