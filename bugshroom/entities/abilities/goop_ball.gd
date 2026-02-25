extends RigidBody3D

const GOOP_ABILITY = preload("res://entities/abilities/goop_ability.tscn")
@onready var ray: RayCast3D = $RayCast3D
@onready var player: CharacterBody3D
@onready var children = get_parent().get_children()

func _ready() -> void:
	for child in children:
		print(child)
		if child is CharacterBody3D:
			player = child
			print(player)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("bug") or body.name == "Floor":
		print("Goop Ball collided with ", body.name)
		var spawnedGoop = GOOP_ABILITY.instantiate()
		add_sibling(spawnedGoop)
		if ray.is_colliding():
			var collisionPoint = ray.get_collision_point()
			if collisionPoint and ray.get_collider().name == "Floor":
				spawnedGoop.position = collisionPoint
				player.ability_icon_animation_player.play("ability_active")
		else:
			print("goop ball floor ray cast didn't hit")
			# if raycast doesnt hit and ball is close to player, just spawn goop puddle under player
			if global_position.distance_to(player.global_position) < 4:
				spawnedGoop.position = player.global_position
				player.ability_icon_animation_player.play("ability_active")
			else:
				player.ability_active = false
				player.ability_cooldown.start()
				player.ability_icon_animation_player.play("cooldown")
		queue_free()
