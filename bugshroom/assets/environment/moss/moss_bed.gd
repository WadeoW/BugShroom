extends StaticBody3D



@onready var bounce_sound_3d: AudioStreamPlayer3D = $BounceSound3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body)
	if body is not RigidBody3D:
		body.velocity.y = 20
		bounce_sound_3d.play()
	if body.is_in_group("aphids"):
		body.velocity.y = 10
		body.velocity.x = randf_range(-15, 15)
		body.velocity.z = randf_range(-15, 15)
	
