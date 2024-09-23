extends Node

class_name GameData

var current_season: int = 0
var current_week: int = 0
var human_index: int = -1
var next_team_slot: int = 0
var next_player_slot: int = 0

var divisions = []
var teams = []
var players = []

var initials = [ "A", "B", "C", "D", "D", "E",
	"F", "G", "G", "H", "I", "J", "K", "L", "M",
	"N", "O", "P", "R", "S", "S", "T", "T", "V", "W" ]


func create_team(team_name: String, division_id: int, formation: GameManager.Formation, price: float) -> Team:
	var team = Team.new()
	team.team_id = next_team_slot
	team.team_name = team_name
	team.division = division_id
	create_new_season_stats(team)
	team.formation = formation
	team.finances = TeamFinances.new()
	team.finances.current_money = randi_range(15, 90) * 10000
	team.finances.income.append([])
	team.finances.expense.append([])
	team.avg_price = price
	
	next_team_slot += 1
	teams.append(team)
	
	return team

func create_new_season_stats(team: Team):
	var team_stats = TeamStats.new()
	team_stats.played = 0
	team_stats.wins = 0
	team_stats.draws = 0
	team_stats.goals_conceded = 0
	team_stats.goals_scored = 0
	team.season_stats.append(team_stats)

func create_player(surnames: Array, position: GameManager.PlayingPosition) -> Player:
	var player = Player.new()
	player.player_id = next_player_slot
	player.player_name = generate_name(initials, surnames)
	player.player_position = position
	player.player_skill = randi_range(1, 9)
	
	next_player_slot += 1
	players.append(player)
	
	return player

func generate_name(initials, surnames):
	return initials.pick_random() + ". " + surnames.pick_random()
