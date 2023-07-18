extends Node

signal match_event
signal possession_changed
signal minute_tick
signal match_ended

var current_minute
var current_home_goals
var current_away_goals

var home_team_possession
var away_team_possession

var current_team_possession

var playing = true
var timer = 0

func _ready():
	current_minute = 0
	current_home_goals = 0
	current_away_goals = 0
	current_team_possession = 0
	
func _process(delta):
	if playing:
		timer += delta
		if timer > 0.5:
			timer = 0
			current_minute += 1#
			emit_signal("minute_tick", current_minute)
			play_match()
		if current_minute == 90:
			playing = false
			emit_signal("match_ended")
	
func set_match(home_team, away_team):
	pass
	
func play_match():
	var random_chance = randi_range(1, 6)
	random_chance += randi_range(1, 6)
	
	if random_chance > 8:
		current_team_possession = 1 if current_team_possession == 0 else 0
		emit_signal("possession_changed", current_team_possession)
	
