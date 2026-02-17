extends BugBase

@export var beetle_speed: float = 4.0
@export var beetle_health: float = 300.0
@export var beetle_damage: float = 40.0
@export var beetle_attack_speed: float = 2.5
@export var knockback_force: float = 20.0
@export var beetle_attack_range: float = 6
@export var beetle_nutrient_value: float = 100

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $beetle_walkanimation/AnimationPlayer
const hit_delay = 0.4 #change with attack animation speed

@onready var health_bar: ProgressBar = $SubViewport/HealthBar3D

#Sound variables
@onready var death_sound_3d: AudioStreamPlayer3D = $Audio/DeathSound3D
@onready var walk_sound_3d: AudioStreamPlayer3D = $Audio/WalkSound3D

@onready var children = get_parent().get_children()
var territory: Area3D = null

func _ready() -> void:
	speed = beetle_speed
	health = beetle_health
	damage = beetle_damage
	attack_range = beetle_attack_range
	aggressive = true
	territorial = true
	add_to_group("beetles")
	add_to_group("bug")
	super._ready()

	health_bar.max_value = beetle_health
	health_bar.value = beetle_health
	
	#sets up beetle's territory
	for child in children:
		if child is Area3D:
			territory = child
			print(child)

	

#func _on_animation_finished(anim_name: StringName):
	#if anim_name == "beetle_animations/beetle_attack2":
		#animation_player.play("beetle_walkanimation")

# this initially checks for a player in the attack hitbox and then plays the attack animation and then waits hit_delay seconds
# to call hit_player which checks again if the player is in the hitbox (so they have a small chance to escape) before applying damage
func _try_attack() -> void:
	if not aggressive:
		return
	if not target or not can_attack:
		return
	var enemyInRange := false
	if attack_hit_box.is_colliding():
		var total_collisions = attack_hit_box.get_collision_count()
		var i = 0
		for collision in range(total_collisions):
			var collidedObject = attack_hit_box.get_collider(i)
			if collidedObject != null and (collidedObject.is_in_group("player") or collidedObject.is_in_group("bug")) and not collidedObject.is_dead:
				enemyInRange = true
			i += 1
		if enemyInRange:
			#animation_player.play("beetle_animations/beetle_attack2")
			animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			can_attack = false
			await get_tree().create_timer(hit_delay).timeout
			hit_enemy()

func hit_enemy() -> void:
	if attack_hit_box.is_colliding():
		var total_collisions = attack_hit_box.get_collision_count()
		var i = 0
		for collision in range(total_collisions):
			var collidedObject = attack_hit_box.get_collider(i)
			if (collidedObject.is_in_group("player") or collidedObject.is_in_group("bug")) and not collidedObject.is_dead:
				print("beetle hit enemy: ", collidedObject.name)
				if collidedObject.has_method("take_damage"):
					collidedObject.take_damage(damage)
				if collidedObject.has_method("apply_knockback"):
					var kb_direction = (collidedObject.global_position - global_position).normalized()
					kb_direction.y = 0.5
					if collidedObject.is_in_group("bug"):
						kb_direction.y = 0.2
					collidedObject.apply_knockback(kb_direction, knockback_force)
			i += 1
		await get_tree().create_timer(beetle_attack_speed).timeout
		can_attack = true

func take_damage(amount: float) -> void:
	animation_tree.set("parameters/TakeDamageOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	if is_dead:
		return
	health -= amount
	_update()
	print(name, " took ", amount, " damage! Health: ", health)
	if health <= 0:
		die()



func _update() -> void:
	health_bar.value = health

func die() -> void:
	death_sound_3d.play()
	animation_tree.set("parameters/Transition/current_state", "dead")
	super.die()
