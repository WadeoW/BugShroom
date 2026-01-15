extends Node3D

@onready var player_type = PlayerData.p2_mushroom_type
@onready var player_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player_type == 0:
		player_scene = load("res://player/amanita/Amanita.tscn")
	elif player_type == 1:
		player_scene = load("res://player/Inkcap/inkcap.tscn")
	elif player_type == PlayerData.MushroomType.Puffball:
		player_scene = load("res://player/Puffshroom/puffball.tscn")
	else:
		print("no player scene")
		
	if player_scene:
		print("player scene set")
		var player_instance = player_scene.instantiate()
		player_instance.position = Vector3(5, 1.3, 22)
		player_instance.player_id = 2
		add_child(player_instance)
