extends Area3D
var creature_in_radius = false
var current_players_in_radius = []
var current_bugs_in_radius = []
var beetle : CharacterBody3D = null
@onready var beetle_scene = preload("res://entities/beetle/beetle.tscn")

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		current_players_in_radius.append(body)
		SignalBus.player_entered_beetle_territory.emit()
		print("new player added to current_players_in_radius")
	if body.is_in_group("ant") or body.is_in_group("aphid"):
		current_bugs_in_radius.append(body)
		print("new bug added to current_bugs_in_radius: " + current_bugs_in_radius)
	creature_in_radius = true
	
func _ready() -> void:
	pass

func spawn_beetle(beetle_scene):
	var spawn = beetle_scene.instantiate()
	add_sibling(spawn)


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and body in current_players_in_radius:
		current_players_in_radius.erase(body)
	if current_players_in_radius == []:
		SignalBus.player_exited_beetle_territory.emit()
