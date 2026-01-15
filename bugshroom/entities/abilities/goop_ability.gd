extends Area3D


#@export var AbilType: Resource
@export var abilDamage: int = 10
@export var abilRadius: int = 3
@export var despawnTime: int = 7


@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var player: CharacterBody3D
@onready var lifetime: Timer = $Lifetime
@onready var damage_tick_timer: Timer = $DamageTickTimer

@onready var children = get_parent().get_children()


var bodies_in_area = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#player = get_tree().get_first_node_in_group("Inkcap")
	#get_parent().get_children()
	
	for child in children:
		print(child)
		if child is CharacterBody3D:
			player = child
			print(player)
			
	#if get_parent().get_node("Player"):
		#player = get_parent().get_node("Player")
	#elif get_parent().get_node("Player2"):
		#player = get_parent().get_node("Player2")
	position = player.position
	print(position)
	print(player.position)
	lifetime.wait_time = despawnTime
	
	for child in children:
		print(child)
		if child is CharacterBody3D:
			player = child
			print(player)


func _on_lifetime_timeout() -> void:
	player.ability_active = false
	print("ability despawned")
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("bug"):
		bodies_in_area.append(body)
		body.speed -= 3
		print(bodies_in_area)
		


func _on_body_exited(body: Node3D) -> void:
	if body in bodies_in_area:
		body.speed += 3
		bodies_in_area.erase(body)
		print(bodies_in_area)


func _on_damage_tick_timer_timeout() -> void:
	var damage = abilDamage
	for body in bodies_in_area:
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("damage ticked")
