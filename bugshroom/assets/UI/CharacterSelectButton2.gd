extends OptionButton

@export var player = 2

func _on_item_selected(index: int) -> void:
		if index == 0:
			PlayerData.p2_mushroom_type = 0
		if index == 1:
			PlayerData.p2_mushroom_type = 1
		if index == 2:
			PlayerData.p2_mushroom_type = 2
		print(PlayerData.p2_mushroom_type)
		var players = get_tree().get_nodes_in_group("player")
		var player_2 = players[1]
		if player_2:
			player_2.in_menu = false

func _on_item_focused(index: int) -> void:
	var players = get_tree().get_nodes_in_group("player")
	var player_2 = players[1]
	player_2.in_menu = true
