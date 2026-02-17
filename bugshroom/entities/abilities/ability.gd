extends Area3D
class_name AbilityBase

#@export var AbilType: Resource
@export var abilDamage: int = 25
@export var abilRadius: int = 8
@export var despawnTime: int = 6


@onready var lifetime: Timer = $Lifetime
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var player: CharacterBody3D

@onready var children = get_parent().get_children()

var bodies_in_area = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for child in children:
		print(child)
		if child is CharacterBody3D:
			player = child
			print(player)
		

	position = player.position
	print(position)
	print(player.position)
	collision_shape_3d.shape.radius = abilRadius

func _on_lifetime_timeout() -> void:
	player.ability_active = false
	print("ability despawned")
	player.ability_cooldown.start()
	player.ability_icon_animation_player.play("cooldown")
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("bug"):
		bodies_in_area.append(body)
		print(bodies_in_area)
		


func _on_body_exited(body: Node3D) -> void:
	if body in bodies_in_area:
		bodies_in_area.erase(body)
		print(bodies_in_area)


func _on_damage_tick_timer_timeout() -> void:
	var damage = abilDamage
	for body in bodies_in_area:
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("damage ticked")
