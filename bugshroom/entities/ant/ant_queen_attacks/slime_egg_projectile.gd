extends RigidBody3D
# CHANGE TO LARVA NOT ANT
@onready var larva_scene = preload("res://entities/ant/ant.tscn") # CHANGE TO LARVA NOT ANT
# CHANGE TO LARVA NOT ANT
var larva_spawn_chance := 0.4
var landing_marker: Area3D
var proj_contact_dmg := 10
var proj_kb_force := 3
var landing_damage := 20
var landing_kb_force := 5

func _ready() -> void:
	await get_tree().process_frame
	# have random rotation
	angular_velocity = randf_range(1, 4) * Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5)).normalized();
	
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage(proj_contact_dmg)
		var kb_dir = ((body.global_position - global_position).normalized() + linear_velocity.normalized()).normalized()
		body.apply_knockback(kb_dir, proj_kb_force)

func _process(delta: float) -> void:
	if global_position.y < 0.3:
		for body in landing_marker.get_overlapping_bodies():
			if body.is_in_group("player"):
				body.take_damage(landing_damage)
				var kb_dir = (body.global_position - landing_marker.global_position).normalized()
				body.apply_knockback(kb_dir, landing_kb_force)
		if randf() <= larva_spawn_chance:
			var spawned_larva = larva_scene.instantiate()
			spawned_larva.global_position = landing_marker.global_position
			# parent is larva_attack whose parent is main/world
			self.get_parent().add_sibling(spawned_larva) # sets spawned_larva parent to world
		landing_marker.queue_free()
		queue_free()
