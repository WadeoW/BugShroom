extends Node3D

@onready var player_type = PlayerData.p2_mushroom_type
@onready var player_scene = PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_player()

func spawn_player() -> void:
	player_type = PlayerData.p2_mushroom_type
	if player_type == 0:
		player_scene = load("res://player/amanita/Amanita.tscn")
	elif player_type == 1:
		player_scene = load("res://player/Inkcap/inkcap.tscn")
	elif player_type == 2:
		player_scene = load("res://player/Puffshroom/puffball.tscn")
	else:
		print("no player scene")
		
	if player_scene:
		print("player scene set")
		var player_instance = player_scene.instantiate()
		player_instance.position = Vector3(5, 1.3, 22)
		player_instance.player_id = 2
		print("Player 2 has spawned as type: ", player_type)
		add_child(player_instance)
		player_instance.name = "Player2"
