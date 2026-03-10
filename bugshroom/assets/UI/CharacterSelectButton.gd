extends OptionButton

@export var player = 1
@onready var players = get_tree().get_nodes_in_group("player")
@onready var player_1 = players[0]


func _ready() -> void:
	if PlayerData.p1_mushroom_type == 0:
		select(0)
	if PlayerData.p1_mushroom_type == 1:
		select(1)
	if PlayerData.p1_mushroom_type == 2:
		select(2)
		
		

func _on_item_selected(index: int) -> void:
	if index == 0:
		PlayerData.p1_mushroom_type = 0
	if index == 1:
		PlayerData.p1_mushroom_type = 1
	if index == 2:
		PlayerData.p1_mushroom_type = 2
	print(PlayerData.p1_mushroom_type)
	var players = get_tree().get_nodes_in_group("player")
	var player_1 = players[0]
	player_1.in_menu = false
	#visible = false



func _on_item_focused(index: int) -> void:
	var players = get_tree().get_nodes_in_group("player")
	var player_1 = players[0]
	player_1.in_menu = true
