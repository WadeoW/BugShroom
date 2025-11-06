extends Node3D

@export var bug_scene: PackedScene          # The bug scene to spawn (e.g. ant.tscn)
@export var max_bugs: int = 15               # Maximum number of bugs active at once
@export var spawn_points: Array[Node3D] = []  # List of spawn point nodes

var active_bugs: Array = []

func _ready():
	# Wait one frame to ensure the scene tree is ready
	await get_tree().process_frame
	spawn_initial_bugs()

#-----------------------------------
# Spawning
#-----------------------------------
func spawn_initial_bugs():
	for i in range(max_bugs):
		spawn_bug()

func spawn_bug():
	if active_bugs.size() >= max_bugs:
		return
	if spawn_points.is_empty():
		push_warning("No spawn points assigned for BugManager!")
		return

	var spawn_point = spawn_points.pick_random()
	var bug = bug_scene.instantiate()
	bug.global_position = spawn_point.global_position
	add_child(bug)
	active_bugs.append(bug)

	# When the bug is removed (dies or despawns), update list
	bug.connect("tree_exited", Callable(self, "_on_bug_despawned").bind(bug))

#-----------------------------------
# Bug Tracking
#-----------------------------------
func _on_bug_despawned(bug):
	if bug in active_bugs:
		active_bugs.erase(bug)
	# Wait 2 seconds before spawning a replacement
		await get_tree().create_timer(2.0).timeout
	if is_inside_tree():
		spawn_bug()
