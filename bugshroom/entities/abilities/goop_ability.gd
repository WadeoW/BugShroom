extends Area3D


#@export var AbilType: Resource
@export var abilDamage: int = 0
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
	player.ability_cooldown.start()
	player.ability_icon_animation_player.play("cooldown")
	queue_free()

	


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("bug"):
		bodies_in_area.append(body)
		body.speed = body.speed * 0.25
		body.rotationSpeed = body.rotationSpeed * 0.5
		print(bodies_in_area)
		


func _on_body_exited(body: Node3D) -> void:
	if body in bodies_in_area:
		body.speed = body.speed * 4
		body.rotationSpeed = body.rotationSpeed * 2
		bodies_in_area.erase(body)
		print(bodies_in_area)


func _on_damage_tick_timer_timeout() -> void:
	pass
	#var damage = abilDamage
	#for body in bodies_in_area:
		#if body.has_method("take_damage"):
			#body.take_damage(damage)
			#print("damage ticked")
