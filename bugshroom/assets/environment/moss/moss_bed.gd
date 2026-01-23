extends StaticBody3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body)
	body.velocity.y = 20
	if body.is_in_group("aphids"):
		body.velocity.y = 20
		body.velocity.x = randf_range(-15, 15)
		body.velocity.x = randf_range(-15, 15)
	
