extends Node

class_name MatchEngine

signal match_event
signal possession_changed
signal ball_position_changed
signal minute_tick
signal match_ended

var current_minute
var current_home_goals
var current_away_goals

var home_team_id
var away_team_id

var match_events = []
var current_event = 0

var current_team_possession

var ball_position

var playing = true
var timer = 0
var match_speed = 0.5

enum MatchEvent { GOAL, HALF_TIME, }
enum MatchTeam { HOME_TEAM = 0, AWAY_TEAM = 1 }

func _ready():
	current_minute = 0
	current_home_goals = 0
	current_away_goals = 0
	current_team_possession = 0
	ball_position = 0
	match_events.clear()
	
func _process(delta):
	if playing:
		timer += delta
		if timer > match_speed:
			timer = 0
			current_minute += 1
			emit_signal("minute_tick", current_minute)
			if current_event < match_events.size():
				var event = match_events[current_event]
				if event.minute == current_minute:
					match event.event_type:
						MatchEvent.HALF_TIME:
							emit_signal("match_event", MatchEvent.HALF_TIME)
						MatchEvent.GOAL:
							if event.team_id == home_team_id:
								current_home_goals += 1
							else:
								current_away_goals += 1
							emit_signal("match_event", MatchEvent.GOAL)
					current_event += 1
		if current_minute == 90:
			playing = false
			emit_signal("match_ended")
	
func set_match(home_team, away_team, events):
	home_team_id = home_team
	away_team_id = away_team
	match_events = events

