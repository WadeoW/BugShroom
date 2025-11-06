extends Node3D

@export var dead_bug_scene: PackedScene

@onready var current_dead_bugs = get_children()
var max_dead_bugs = 8

#spawn area variables
var spawn_area_min_x = -350
var spawn_area_max_x = 350
var spawn_area_min_z = -350
var spawn_area_max_z = 350

@onready var spawn_timer: Timer = $SpawnTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if dead_bug_scene == null:
		print("dead bug scene not set")
	spawn_timer.start()

func _on_dead_bug_task_finished():
	if current_dead_bugs.size() > 0:
		current_dead_bugs.erase(dead_bug_scene)
	else:
		print("no more bugs!")

func _on_spawn_timer_timeout() -> void:
	if current_dead_bugs.size() < max_dead_bugs:
		spawn_dead_bug_task()
	
	
func spawn_dead_bug_task():
	if dead_bug_scene == null:
		return
		
	var dead_bug_instance = dead_bug_scene.instantiate()
	
	var random_x = randf_range(spawn_area_min_x, spawn_area_max_x)
	var random_z = randf_range(spawn_area_min_z, spawn_area_max_z)
	
	dead_bug_instance.position = Vector3(random_x, 1.0, random_z)
	
	add_child(dead_bug_instance)
	current_dead_bugs.append(dead_bug_instance)
