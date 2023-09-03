extends Control

@onready var player_name_label = $Panel/PlayerName
@onready var offer_box = $Panel/HBoxContainer/OfferBox
@onready var team_bids = $Panel/Bids/Teams
@onready var offer_bids = $Panel/Bids/Offer
@onready var accepted_text = $Panel/AcceptedBid
@onready var submit_button = $Panel/HBoxContainer/SubmitBid

@onready var bid_player_settings = preload("res://Themes/bid_player_settings.tres")
@onready var scout_view = preload("res://Scenes/scout_view.tscn")

var bid : Bid
var current_offer = 100

var team_offers = []
var offer_amounts = []

func _ready():
	bid = GameManager.queued_bids.pop_back()
	current_offer = bid.price / 1000
	var player = GameManager.get_player_by_id(bid.player)
	player_name_label.text = player.player_name
	offer_box.text = str(current_offer) + "K"
	cleanup()
	accepted_text.hide()

func _on_offer_box_text_changed(new_text : String):
	var changed_text = new_text.trim_suffix("K")
	print(changed_text)
	print(new_text)
	if changed_text.is_valid_int():
		current_offer = changed_text.to_int()
	else:
		offer_box.text = str(current_offer) + "K"

func _on_submit_bid_pressed():
	cleanup()
	
	# Choose 3 teams that want to buy the player
	for i in range(3):
		team_offers.append(GameManager.teams.pick_random())
		offer_amounts.append(current_offer + randi_range(-20, 20))

	# create the offers
	for i in team_offers.size():
		var team_label = Label.new()
		team_label.label_settings = bid_player_settings
		team_label.text = team_offers[i].team_name
		team_bids.add_child(team_label)
		var offer_label = Label.new()
		offer_label.label_settings = bid_player_settings
		offer_label.text = str(offer_amounts[i])
		offer_bids.add_child(offer_label)
	
	submit_button.disabled = true
	
	accepted_text.text = GameManager.buy_player(bid.player, current_offer * 1000)
	accepted_text.show()

func cleanup():
	for child in team_bids.get_children():
		child.queue_free()
		team_bids.remove_child(child)
	for child in offer_bids.get_children():
		child.queue_free()
		offer_bids.remove_child(child)
	team_offers.clear()
	offer_amounts.clear()


func _on_back_button_pressed():
	cleanup()
	get_tree().root.remove_child(self)


func _on_button_pressed():
	current_offer += 10
	offer_box.text = str(current_offer) + "K"


func _on_button_down_pressed():
	current_offer -= 10
	offer_box.text = str(current_offer) + "K"
