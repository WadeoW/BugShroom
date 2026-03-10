extends RigidBody3D

const GOOP_ABILITY = preload("res://entities/abilities/goop_ability.tscn")
@onready var ray: RayCast3D = $RayCast3D
@onready var player: CharacterBody3D
@onready var children = get_parent().get_children()
var bounces = 0
const max_bounces = 3
var ball_inactive_timer := 0.0
var max_ball_inactive_timer := 7

func _ready() -> void:
	for child in children:
		print(child)
		if child is CharacterBody3D:
			player = child
			print(player)
	await get_tree().create_timer(0.5).timeout
	remove_collision_exception_with(player)

func _physics_process(delta: float) -> void:
	ball_inactive_timer += delta
	if linear_velocity.length() < 0.2 or ball_inactive_timer > max_ball_inactive_timer:
		player.ability_active = false
		player.can_cast_abil = true
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("bug") or body.name == "Floor" or body.is_in_group("anthill_walls"):
		if ray.is_colliding():
			var collisionPoint = ray.get_collision_point()
			if collisionPoint and (ray.get_collider().name == "Floor" or ray.get_collider().is_in_group("anthill_walls")):
				var normal: Vector3 = ray.get_collision_normal()
				var slope_angle_deg := rad_to_deg(normal.angle_to(Vector3.UP))
				if slope_angle_deg < 20:
					print("Goop Ball collided with ", body.name)
					var spawnedGoop = GOOP_ABILITY.instantiate()
					add_sibling(spawnedGoop)
					bounces += 1
					ball_inactive_timer = 0
					spawnedGoop.position = collisionPoint
					spawnedGoop.global_transform.basis = Basis.looking_at(-spawnedGoop.global_transform.basis.z, normal)
					player.ability_icon_animation_player.play("ability_active")
		else:
			print("goop ball floor ray cast didn't hit")
			# if raycast doesnt hit and ball is close to player, just spawn goop puddle under player
			if global_position.distance_to(player.global_position) < 4:
				print("Goop Ball collided with ", body.name)
				var spawnedGoop = GOOP_ABILITY.instantiate()
				add_sibling(spawnedGoop)
				spawnedGoop.position = player.global_position
				player.ability_icon_animation_player.play("ability_active")
			else:
				player.ability_active = false
				player.ability_cooldown.start()
				player.ability_icon_animation_player.play("cooldown")
		if bounces >= max_bounces:
			queue_free()
