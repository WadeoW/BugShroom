extends Node3D

@onready var animation_tree: AnimationTree = $"../AnimationTree"
@onready var player: CharacterBody3D = get_parent()



func _physics_process(delta: float) -> void:
	

	var idle = !player.velocity
	
	animation_tree.set("parameters/AnimationNodeStateMachine/run/blend_position", lerp(player.velocity.length(), 0.0, 0.2))
	animation_tree.set("parameters/TimeScale/scale", clamp(lerp(0.0, player.velocity.length()/2, 1.0), 1, 2))

	
	if player.is_jumping == true:
		animation_tree.set("parameters/AnimationNodeStateMachine/conditions/is_jumping", true)
		animation_tree.set("parameters/AnimationNodeStateMachine/conditions/is_on_ground", false)
	else:
		animation_tree.set("parameters/AnimationNodeStateMachine/conditions/is_jumping", false)
		animation_tree.set("parameters/AnimationNodeStateMachine/conditions/is_on_ground", true)
		
	
	
	#if player.is_rooted == true:
		#animation_tree.set("parameters/conditions/is_rooted", true)
	#else:
		#animation_tree.set("parameters/conditions/is_rooted", false)
	
	#if player.is_attacking == true:
		#animation_tree.set("parameters/conditions/is_attacking", true)
	#else:
		#animation_tree.set("parameters/conditions/is_attacking", false)

	#if player.is_dead == true:
		#animation_tree.set("parameters/conditions/is_dead", true)
	#else:
		#animation_tree.set("parameters/conditions/is_dead", false)
		
