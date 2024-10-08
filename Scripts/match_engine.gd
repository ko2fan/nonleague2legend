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
var current_home_shots_on_target
var current_away_shots_on_target
var current_home_corners
var current_away_corners

var home_team_id
var away_team_id

var match_events = []

var playing = true
var timer = 0
var match_speed = 0.5
var players_booked = []
var players_sentoff = []

enum MatchEventType { GOAL, HALF_TIME, YELLOW_CARD, RED_CARD, SHOT_ON_TARGET, CORNER }
enum MatchTeam { HOME_TEAM = 0, AWAY_TEAM = 1 }

func _ready():
	current_minute = 0
	current_home_goals = 0
	current_away_goals = 0
	current_home_shots_on_target = 0
	current_away_shots_on_target = 0
	current_home_corners = 0
	current_away_corners = 0
	match_events.clear()
	
func _process(delta):
	if playing:
		timer += delta
		if timer > match_speed:
			timer = 0
			current_minute += 1
			emit_signal("minute_tick", current_minute)
			var events = match_events.filter(func(event_): return event_.minute == current_minute)
			for event in events:
				match event.event_type:
					MatchEventType.GOAL:
						if event.team_id == home_team_id:
							current_home_goals += 1
						else:
							current_away_goals += 1
					MatchEventType.HALF_TIME:
						pass # do nothing for now
					MatchEventType.SHOT_ON_TARGET:
						if event.team_id == home_team_id:
							current_home_shots_on_target += 1
						else:
							current_away_shots_on_target += 1
					MatchEventType.CORNER:
						if event.team_id == home_team_id:
							current_home_corners += 1
						else:
							current_away_corners += 1
					MatchEventType.YELLOW_CARD:
						# if player already booked, send them off
						if event.player_id in players_booked:
							players_sentoff.append(event.player_id)
							event.event_type = MatchEventType.RED_CARD
						else:
							players_booked.append(event.player_id)
					MatchEventType.RED_CARD:
						players_sentoff.append(event.player_id)
				emit_signal("match_event", event.event_type, event)
		if current_minute == 90:
			playing = false
			emit_signal("match_ended")
	
func set_match(home_team, away_team, events):
	home_team_id = home_team
	away_team_id = away_team
	match_events = events

# YELLOW CARD RULES
# Five yellows accumulated before match week 19 results in a one-match ban.
# Ten yellows accumulated by week 32 will result in a two-match ban.
# Fifteen yellows by week 38 means a three-match ban.
# For a sending off, after a second yellow in one game, the suspension period is one match.
# For a so-called professional foul, a player will also receive a one-match ban.
# If the foul in question is dissent, it will normally be a two-match ban.
# If we are talking about violent conduct, the punishment is normally a three-match ban.

