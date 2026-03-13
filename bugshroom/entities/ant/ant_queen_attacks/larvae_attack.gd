extends Node3D

@onready var projectile = preload("res://entities/ant/ant_queen_attacks/slime_egg_projectile.tscn")
@onready var landing_marker = preload("res://entities/ant/ant_queen_attacks/landing_marker.tscn")
@onready var destroy_timer: Timer = $destroy_timer

var flight_time := 3.2
var launch_interval_time := 0.25
var projectiles := 4
var parent_queen

func _ready() -> void:
	await get_tree().process_frame
	destroy_timer.start(flight_time + 4 * launch_interval_time)
	var closest_player = _get_closest_in_group("player")
	for i in range(projectiles):
		var proj = projectile.instantiate()
		add_child(proj)
		proj.global_position = global_position
		proj.parent_queen = parent_queen
		# random position around the player and disregard y value (always on ground)
		var landing_position = Vector3(closest_player.global_position.x, 0, closest_player.global_position.z) + Vector3(randf_range(-5,5), 0, randf_range(-5,5))
		print("landing position is ", landing_position)
		var land = landing_marker.instantiate()
		proj.landing_marker = land
		add_child(land)
		land.global_position = landing_position
		proj.linear_velocity = arcing_velocity(global_position, landing_position, flight_time)
		await get_tree().create_timer(launch_interval_time).timeout

func _on_timer_timeout() -> void:
	queue_free()

func arcing_velocity(pos0: Vector3, pos1: Vector3, landing_time: float) -> Vector3:
	var distance := pos1 - pos0
	var x = distance.x / landing_time
	var y = (distance.y + 0.5 * 9.8 * landing_time * landing_time) / landing_time
	var z = distance.z / landing_time
	return Vector3(x, y, z) * 1.1 # random number to adjust for it being a bit too short, seems to work fine

func _get_closest_in_group(group: String ) -> Node3D:
	var nodes := get_tree().get_nodes_in_group(group)
	if nodes.is_empty():
		return null
	var closest: Node3D = null
	var closest_dist := INF
	for n in nodes:
		if n and n.is_inside_tree() and self != n:
			var node := n as Node3D
			var dist := global_position.distance_to(node.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = node
	return closest
