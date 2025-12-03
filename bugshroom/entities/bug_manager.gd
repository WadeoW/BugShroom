extends Node3D

@export var bug_scene: PackedScene              # Which bug scene this manager spawns (ant.tscn, beetle.tscn, aphid.tscn)
@export var max_bugs: int = 15                  # Max bugs THIS manager can have at once

# Global random spawn area (XZ plane)
@export var spawn_area_min_x: float = -350.0
@export var spawn_area_max_x: float = 350.0
@export var spawn_area_min_z: float = -350.0
@export var spawn_area_max_z: float = 350.0

# Tracks ONLY the bugs this manager has spawned
var active_bugs: Array[Node3D] = []

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	if bug_scene == null:
		push_warning("BugManager: bug_scene is not set!")
	
	randomize()
	spawn_timer.start()
	SignalBus.bug_died.connect(Callable(self, "_on_bug_died"))
#debug
	#print(current_bugs.size(), current_bugs)




func _on_spawn_timer_timeout() -> void:
	# Only spawn if we're under the cap
	if active_bugs.size() < max_bugs:
		spawn_bug()


func spawn_bug() -> void:
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
	
	var bug_instance: Node3D = bug_scene.instantiate()

	# Random position in the area
	var random_x = randf_range(spawn_area_min_x, spawn_area_max_x)
	var random_z = randf_range(spawn_area_min_z, spawn_area_max_z)
	bug_instance.global_position = Vector3(random_x, 1.0, random_z)

	add_child(bug_instance)
	active_bugs.append(bug_instance)

	# When this bug leaves the tree (die/queue_free), remove it from our list
	bug_instance.connect(
		"tree_exited",
		Callable(self, "_on_bug_exited").bind(bug_instance)
	)


func _on_bug_exited(bug: Node3D) -> void:
	if bug in active_bugs:
		active_bugs.erase(bug)
