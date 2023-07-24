extends VBoxContainer

func set_player(texture, player_name):
	$Shirt.texture = texture
	$Label.text = player_name
	$Label.show()
