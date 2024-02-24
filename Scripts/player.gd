extends Node
class_name Player

var player_id := -1
var player_name: String
var player_position := GameManager.PlayingPosition.ANY
var player_skill := 0
var squad_number := -1
var team : Team
var matches_played := 0
var goals_scored := 0
var yellow_cards := 0
var suspended := 0
