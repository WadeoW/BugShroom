extends Node

enum MushroomType {
	Amanita,
	Inkcap,
	Puffball
}
@onready var player_1 = get_tree().get("Player")
@onready var player_2 = get_tree().get("Player2")

var p1_mushroom_type = MushroomType.Amanita
var p2_mushroom_type = MushroomType.Puffball

#func _ready() -> void:
	#player_1.mushroom_type = p1_mushroom_type
	#player_2.mushroom_type = p2_mushroom_type
	#print(player_1.mushroom_type)
	#print(player_2.mushroom_type)
