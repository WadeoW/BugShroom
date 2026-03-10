extends Node3D

@onready var player_type = PlayerData.p1_mushroom_type
@onready var player_scene = PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_player()

func spawn_player() -> void:
	player_type = PlayerData.p1_mushroom_type
	if player_type == 0:
		player_scene = load("res://player/amanita/Amanita.tscn")
		print("player scene = amanita")
	elif player_type == 1:
		player_scene = load("res://player/Inkcap/inkcap.tscn")
		print("player scene = inkcap")
	elif player_type == 2:
		player_scene = load("res://player/Puffshroom/puffball.tscn")
		print("player scene = puffball")
		
	if player_scene:
		var player_instance = player_scene.instantiate()
		player_instance.position = Vector3(-5, 1.3, 22)
		player_instance.player_id = 1
		print("player 1 spawned is as type: ", player_type)
		add_child(player_instance)
		player_instance.name = "Player1"
