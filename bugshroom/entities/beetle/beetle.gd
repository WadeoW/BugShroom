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

# charge attack variables
@export var charge_acceleration: float = 17.5
var charge_max_speed: float = 25
var charge_rotation_speed: float = 2
var charge_direction: Vector3
var is_charging: bool = false
var can_charge: bool = true
var has_hit_enemy_with_charge: bool = false
var enemies_hit_with_charge = []
var charge_target: Node3D
@onready var charge_duration_timer: Timer = $ChargeDurationTimer
@onready var charge_cooldown_timer: Timer = $ChargeCooldownTimer

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
func _physics_process(delta: float) -> void:
	if can_charge:
		var closest_bug = super._get_closest_in_group("bug")
		var closest_player = super._get_closest_in_group("player")
		if (is_chasing):
			charge_target = closest_player
			is_charging = true
		if (is_chasing_bug):
			charge_target = closest_bug
			is_charging = true
		if is_charging:
			can_charge = false
			has_hit_enemy_with_charge = false
			charge_direction = charge_target.global_position - global_position
			charge_direction.y = 0
			charge_direction = charge_direction.normalized()
			charge_duration_timer.start()
			velocity = velocity * 0.5
	
	if not is_charging:
		super._physics_process(delta)
		return
	
	if not charge_target:
		return
	
	var desired
	if not has_hit_enemy_with_charge:
		desired = charge_target.global_position - global_position
		desired.y = 0
		desired = desired.normalized()
		var vel := Vector3(velocity.x, 0, velocity.z)
		if vel.length() > 0.01:
			var t = clamp(charge_rotation_speed * delta, 0.0, 1.0)
			var new_dir := vel.normalized().slerp(desired, t)
			vel = new_dir * vel.length()
			velocity.x = vel.x
			velocity.z = vel.z
	else:
		desired = Vector3.ZERO
	
	velocity.x += (charge_direction.x * charge_acceleration + desired.x) * delta
	velocity.z += (charge_direction.z * charge_acceleration + desired.z) * delta
	var clamped_velocity = Vector2(velocity.x, velocity.z).limit_length(charge_max_speed)
	velocity.x = clamped_velocity.x
	velocity.z = clamped_velocity.y
	
	_rotate_to_velocity(delta, 3 * rotationSpeed)
	move_and_slide()
	
	# collision for actual beetle body during charge
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collidedObject := collision.get_collider()
		if (collidedObject.is_in_group("player") or collidedObject.is_in_group("bug")) and not collidedObject.is_dead:
			has_hit_enemy_with_charge = true
			enemies_hit_with_charge.append(collidedObject)
			add_collision_exception_with(collidedObject)
			if collidedObject.has_method("take_damage"):
				collidedObject.take_damage(damage)
			if collidedObject.has_method("apply_knockback"):
				var kb_direction = (collidedObject.global_position - global_position).normalized()
				kb_direction.y = 0.4
				if collidedObject.is_in_group("bug"):
					kb_direction.y = 0.2
				collidedObject.apply_knockback(kb_direction, knockback_force * 2)

func _on_charge_duration_timer_timeout() -> void:
	for object in enemies_hit_with_charge:
		if object != null:
			remove_collision_exception_with(object)
	enemies_hit_with_charge.clear()
	is_charging = false
	charge_cooldown_timer.start()

func _on_charge_cooldown_timer_timeout() -> void:
	can_charge = true

# this initially checks for a player in the attack hitbox and then plays the attack animation and then waits hit_delay seconds
# to call hit_player which checks again if the player is in the hitbox (so they have a small chance to escape) before applying damage
func _try_attack() -> void:
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
