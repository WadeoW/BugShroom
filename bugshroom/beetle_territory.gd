extends Area3D
var creature_in_radius = false
var current_players_in_radius = []
var current_bugs_in_radius = []
var beetle : CharacterBody3D = null
@onready var beetle_scene = preload("res://entities/beetle/beetle.tscn")
@onready var respawn_timer: Timer = $Respawn
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var first_spawn := true

func _process(delta: float) -> void:
	if first_spawn:
		spawn_beetle()
		first_spawn = false
	if beetle == null && respawn_timer.is_stopped():
		respawn_timer.start()

func _on_respawn_timeout() -> void:
	spawn_beetle()

func _on_body_entered(body: Node3D) -> void:
	if body == beetle:
		beetle.in_territory = true
	if body.is_in_group("player"):
		current_players_in_radius.append(body)
		SignalBus.player_entered_beetle_territory.emit()
		print("new player added to current_players_in_radius")
	if body.is_in_group("ant") or body.is_in_group("aphid"):
		current_bugs_in_radius.append(body)
		print("new bug added to current_bugs_in_radius: " + current_bugs_in_radius)
	creature_in_radius = true

func spawn_beetle():
	var spawned_beetle = beetle_scene.instantiate()
	get_tree().current_scene.add_child(spawned_beetle)
	beetle = spawned_beetle
	print("spawner parent:", get_parent(), " spawner in tree:", is_inside_tree())
	print("beetle parent:", beetle.get_parent(), " beetle in tree:", beetle.is_inside_tree())
	beetle.position = position + Vector3.UP * 0.25

func _on_body_exited(body: Node3D) -> void:
	if body == beetle:
		beetle.in_territory = false
	if body.is_in_group("player") and body in current_players_in_radius:
		current_players_in_radius.erase(body)
	
	if current_players_in_radius == []:
		SignalBus.player_exited_beetle_territory.emit()
