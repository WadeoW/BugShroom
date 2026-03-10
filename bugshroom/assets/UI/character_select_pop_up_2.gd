extends ScrollContainer



@onready var option_button_2: OptionButton = $VBoxContainer/OptionButton2
@export var identifier = 2
@onready var players = get_tree().get_nodes_in_group("player")
@onready var player_2 = players[1]


func _ready() -> void:
	if PlayerData.p2_mushroom_type == 0:
		option_button_2.select(0)
	if PlayerData.p2_mushroom_type == 1:
		option_button_2.select(1)
	if PlayerData.p2_mushroom_type == 2:
		option_button_2.select(2)
		


func _on_option_button_2_item_focused(index: int) -> void:
	var players = get_tree().get_nodes_in_group("player")
	var player_2 = players[1]
	player_2.in_menu = true


func _on_option_button_2_item_selected(index: int) -> void:
	if index == 0:
		PlayerData.p2_mushroom_type = 0
	if index == 1:
		PlayerData.p2_mushroom_type = 1
	if index == 2:
		PlayerData.p2_mushroom_type = 2
	print(PlayerData.p2_mushroom_type)
	var players = get_tree().get_nodes_in_group("player")
	var player_2 = players[1]
	player_2.in_menu = false
	#visible = false
