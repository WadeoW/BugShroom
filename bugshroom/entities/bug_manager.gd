extends Node3D

@export var bug_scene: PackedScene              # Which bug scene this manager spawns (ant.tscn, beetle.tscn, aphid.tscn)
@export var max_bugs: int = 15                  # Max bugs THIS manager can have at once

# Global random spawn area (XZ plane)
@export var spawn_area_min_x: float = -350.0
@export var spawn_area_max_x: float = 350.0
@export var spawn_area_min_z: float = -350.0
@export var spawn_area_max_z: float = 350.0

# Tracks ONLY the bugs this manager has spawned
var active_bugs: Array = []

@export var spawn_timer: Timer 
var bug_type = ""

func _ready() -> void:
	if bug_scene == null:
		push_warning("BugManager: bug_scene is not set!")
	
	randomize()
	#spawn_timer.start()
	SignalBus.bug_died.connect(Callable(self, "_on_bug_died"))
	
	if bug_scene == load("res://entities/beetle/beetle.tscn"):
		active_bugs = get_tree().get_nodes_in_group("beetles")
		bug_type = "beetles"
	if bug_scene == load("res://entities/aphid/aphid.tscn"):
		active_bugs = get_tree().get_nodes_in_group("aphids")
		bug_type = "aphids"
	if bug_scene == load("res://entities/ant/ant.tscn"):
		active_bugs = get_tree().get_nodes_in_group("ants")
		bug_type = "ants"
#debug
	#print(current_bugs.size(), current_bugs)
	#print(active_bugs)
	#print(bug_type)

func get_random_pos():
	var random_x = randf_range(spawn_area_min_x, spawn_area_max_x)
	var random_z = randf_range(spawn_area_min_z, spawn_area_max_z)
	return Vector3(random_x, 2, random_z)


func _on_bug_died():
	if active_bugs.size() > 0:
		active_bugs.remove_at(0)
		print("diva down")
		#print("current bug count: ", current_bugs.size())
	else:
		print("no more bugs!")

	
func spawn_bug():
	if bug_scene == null:
		print("bug scene null")
		return
	
	var bug_instance = bug_scene.instantiate()

	bug_instance.position = Vector3(get_random_pos())

	add_child(bug_instance)
	active_bugs.append(bug_instance)
	
	##debug messages
	#print("bug spawned, current bugs = ", active_bugs.size())
	#print("bug is type: ", bug_type)
	#print(bug_instance.position)
	#print(active_bugs)


	## When this bug leaves the tree (die/queue_free), remove it from our list
	#bug_instance.connect(
		#"tree_exited",
		#Callable(self, "_on_bug_exited").bind(bug_instance)
	#)

#func _on_bug_exited(bug: Node3D) -> void:
	#if bug in active_bugs:
		#active_bugs.erase(bug)
		#print(bug, " exited")
		#print(active_bugs)
		
func _on_spawn_timer_timeout() -> void:
	#if bug_type == "ant":
		# Only spawn if we're under the cap
		if active_bugs.size() < max_bugs:
			print("trying to spawn bug")
			spawn_bug()




func _on_spawn_timer_1_timeout() -> void:
	#if bug_type == "beetle":
		# Only spawn if we're under the cap
		if active_bugs.size() < max_bugs:
			print("trying to spawn bug")
			spawn_bug()
			



func _on_spawn_timer_2_timeout() -> void:
	#if bug_type == "aphid":
		# Only spawn if we're under the cap
		if active_bugs.size() < max_bugs:
			print("trying to spawn bug")
			spawn_bug()
