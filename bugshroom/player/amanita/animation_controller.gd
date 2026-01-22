extends Node3D

@onready var animation_tree: AnimationTree = $"../AnimationTree"
@onready var player: CharacterBody3D = get_parent()





func _physics_process(delta: float) -> void:
	
	
	var idle = !player.velocity
	
	animation_tree.set("parameters/run/blend_position", lerp(player.velocity.length(), 0.0, 0.2))
	if player.is_jumping == true:
		animation_tree.set("parameters/conditions/is_jumping", true)
		animation_tree.set("parameters/conditions/is_on_ground", false)
	else:
		animation_tree.set("parameters/conditions/is_jumping", false)
		animation_tree.set("parameters/conditions/is_on_ground", true)
