extends Node3D

@export var dead_bug_scene: PackedScene

@onready var current_dead_bugs = get_tree().get_nodes_in_group("dead_bug_task")
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
#debug
	#print(current_dead_bugs)
	#print("current dead bug size: ", current_dead_bugs.size())
	
	SignalBus.dead_bug_task_finished.connect(Callable(self, "_on_dead_bug_task_finished"))


func get_random_pos():
	var random_x = randf_range(spawn_area_min_x, spawn_area_max_x)
	var random_z = randf_range(spawn_area_min_z, spawn_area_max_z)
	return Vector3(random_x, 1, random_z)

#func check_valid_spawn_point(dead_bug_instance: PackedScene):
	#var dead_bug_area = dead_bug_instance.get_tree().get_nodes_in_group("OverlappingBodiesDetector")
	#if dead_bug_area.has_overlapping_bodies():
		#return false
	#else:
		#return true

func _on_dead_bug_task_finished():
	if current_dead_bugs.size() > 0:
		current_dead_bugs.remove_at(0)
		print("dead bug go bye bye ", current_dead_bugs.size(), current_dead_bugs)
	else:
		print("no more bugs!")

func _on_spawn_timer_timeout() -> void:
	if current_dead_bugs.size() < max_dead_bugs:
		spawn_dead_bug_task()
	
	
func spawn_dead_bug_task():
	if dead_bug_scene == null:
		print("dead_bug_scene is null")
		return
		
	var dead_bug_instance = dead_bug_scene.instantiate()
	dead_bug_instance.position = Vector3(get_random_pos())
	
	#if check_valid_spawn_point(dead_bug_instance) == false:
		#dead_bug_instance.position = Vector3(get_random_pos())
	
	add_child(dead_bug_instance)
	current_dead_bugs.append(dead_bug_instance)
#debug
	print("spawned a new bug task. currently there are: ", current_dead_bugs.size())
