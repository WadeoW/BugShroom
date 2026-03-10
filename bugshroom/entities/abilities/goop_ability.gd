extends Area3D


#@export var AbilType: Resource
@export var abilDamage: int = 4
@export var abilSlowdown := 0.5
@export var healing: int = 2
@export var abilRadius: int = 4
@export var despawnTime: int = 7

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var player: CharacterBody3D
@onready var lifetime: Timer = $Lifetime
@onready var damage_tick_timer: Timer = $DamageTickTimer
@onready var children = get_parent().get_children()

var bodies_in_area = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in children:
		print(child)
		if child is CharacterBody3D:
			player = child
			print(player)
	#debug
	print(position)
	print(player.position)
	
	lifetime.wait_time = despawnTime #set timer to despawn timer
	

func _on_lifetime_timeout() -> void:
	player.ability_active = false
	print("ability despawned")
	if player.ability_cooldown.is_stopped():
		player.ability_cooldown.start()
	player.ability_icon_animation_player.play("cooldown")
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("bug"):
		bodies_in_area.append(body)
		body.speed = body.speed * abilSlowdown
		if body.is_in_group("beetles"):
			body.charge_max_speed = body.charge_max_speed * (abilSlowdown + 0.2)
		body.rotationSpeed = body.rotationSpeed * abilSlowdown
	if body.is_in_group("player"):
		bodies_in_area.append(body)


func _on_body_exited(body: Node3D) -> void:
	if body in bodies_in_area && body.is_in_group("bug"):
		body.speed = body.speed / abilSlowdown
		if body.is_in_group("beetles"):
			body.charge_max_speed = body.charge_max_speed / (abilSlowdown + 0.2)
		body.rotationSpeed = body.rotationSpeed / abilSlowdown
		bodies_in_area.erase(body)
		print(bodies_in_area)
	if body in bodies_in_area && body.is_in_group("player"):
		bodies_in_area.erase(body)

func _on_damage_tick_timer_timeout() -> void:
	for body in bodies_in_area:
		if body.has_method("take_damage"):
			if body.is_in_group("bug"):
				body.take_damage(abilDamage)
			if body.is_in_group("player"):
				body.heal(healing)
			print("damage ticked")
