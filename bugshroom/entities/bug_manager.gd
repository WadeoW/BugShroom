extends Node3D

@export var bug_scene: PackedScene          # The bug scene to spawn (e.g. ant.tscn)
@export var max_bugs: int = 20               # Maximum number of bugs active at once
@export var spawn_points: Array[Node3D] = []  # List of spawn point nodes

var active_bugs: Array = []

@onready var current_bugs = get_tree().get_nodes_in_group("bug")


#spawn area variables
var spawn_area_min_x = -350
var spawn_area_max_x = 350
var spawn_area_min_z = -350
var spawn_area_max_z = 350

@onready var spawn_timer: Timer = $SpawnTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if bug_scene == null:
		print("dead bug scene not set")
	spawn_timer.start()
	print(current_bugs.size(), current_bugs)
	SignalBus.bug_died.connect(Callable(self, "_on_bug_died"))


func _on_bug_died():
	if current_bugs.size() > 0:
		current_bugs.remove_at(0)
		print("diva down")
		#print("current bug count: ", current_bugs.size())
	else:
		print("no more bugs!")

func _on_spawn_timer_timeout() -> void:
	if current_bugs.size() < max_bugs:
		#print("trying to spawn bug")
		spawn_bug()
	
func spawn_bug():
	if bug_scene == null:
		print("bug scene null")
		return
		
	var bug_instance = bug_scene.instantiate()
	
	var random_x = randf_range(spawn_area_min_x, spawn_area_max_x)
	var random_z = randf_range(spawn_area_min_z, spawn_area_max_z)
	
	bug_instance.position = Vector3(random_x, 1.0, random_z)
	
	add_child(bug_instance)
	current_bugs.append(bug_instance)
	#print("ant spawned at: ", bug_instance.position, " current bug total is: ", current_bugs.size())
