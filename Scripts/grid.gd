extends VBoxContainer

func set_player(texture, player_name, position_colour):
	$Shirt.texture = texture
	$Shirt.modulate = position_colour
	$Label.text = player_name
	$Label.show()

func clear_player():
	$Shirt.texture = null
	$Shirt.modulate = Color.WHITE
	$Label.text = ""
	$Label.hide()
