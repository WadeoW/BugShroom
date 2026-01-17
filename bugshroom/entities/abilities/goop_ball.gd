extends RigidBody3D

const GOOP_ABILITY = preload("res://entities/abilities/goop_ability.tscn")
@onready var ray: RayCast3D = $RayCast3D


func _on_body_entered(body: Node) -> void:
	print("Goop Ball collided with ", body.name)
	var spawnedGoop = GOOP_ABILITY.instantiate()
	add_sibling(spawnedGoop)
	var collisionPoint = ray.get_collision_point()
	if collisionPoint and ray.get_collider().name == "Floor":
		spawnedGoop.position = collisionPoint + Vector3.UP * 0.1
	queue_free()
