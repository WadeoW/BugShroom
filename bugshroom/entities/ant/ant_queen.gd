extends BugBase

@export var ant_speed: float = 5.0
@export var ant_health: float = 1000.0
@export var ant_damage: float = 80.0
#sound variables
@onready var hit_sound_3d: AudioStreamPlayer3D = $Audio/HitSound3D
@onready var walk_sound_3d: AudioStreamPlayer3D = $Audio/WalkSound3D
@onready var death_sound_3d: AudioStreamPlayer3D = $Audio/DeathSound3D
@onready var attack_sound_3d: AudioStreamPlayer3D = $Audio/AttackSound3D
#healthbar variables
@onready var health_bar_3d: ProgressBar = $SubViewport/HealthBar3D
# attack variables
@onready var larvae_attack = preload("res://entities/ant/ant_queen_attacks/larvae_attack.tscn")
@onready var larvae_attack_spawnpoint: Node3D = $"larvae attack spawnpoint"
#collectible variables
@onready var ant_queen_head = preload("res://entities/Collectibles/Ant_Queen_Head/ant_queen_collectible.tscn")

#Animation variables
@onready var animation_player: AnimationPlayer = $antqueen_animations/AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree


func _ready():
	speed = ant_speed
	health = ant_health
	damage = ant_damage
	aggressive = true
	scavenger = false
	detection_range = 10
	add_to_group("ants")
	add_to_group("bug")
	super._ready()
	health_bar_3d.max_value = ant_health
	health_bar_3d.value = ant_health

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	# Manually get rid of knockback over time
	knockback = knockback.move_toward(Vector2.ZERO, 20 * delta)
	if is_dead:
		if should_shrink_on_death:
			scale = scale.move_toward(Vector3(0.5, 0.5, 0.5), delta)
		if not is_being_carried:
			move_and_slide()
		return
	# Only aggressive bugs look for players
	if aggressive:
		target = _get_closest_in_group("player")
		var closest_taunt_ability = _get_closest_in_group("taunt_ability")
		if closest_taunt_ability != null and (global_position.distance_to(closest_taunt_ability.global_position) < global_position.distance_to(target.global_position)):
			target = closest_taunt_ability
	else:
		target = null  # passive bugs don't chase at all
	if aggressive and target:
		var distance := global_position.distance_to(target.global_position)
		# Chase player if within detection range
		if distance <= detection_range:
			is_chasing = true
			_chase_target(target)
			_try_attack()
		else:
			is_chasing = false
			_idle_behavior(delta)
	else:
		# Passive bugs or no close enough target: just wander
		is_chasing = false
		_idle_behavior(delta)
		

func _on_larvae_attack_timer_timeout() -> void:
	print("larvae attacking")
	animation_tree.set("parameters/SummonAntOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	var distance := global_position.distance_to(_get_closest_in_group("player").global_position)
	if distance <= detection_range * 3:
		var attack = larvae_attack.instantiate()
		add_sibling(attack)
		attack.global_position = larvae_attack_spawnpoint.global_position
		

func _try_attack() -> void:
	if not aggressive:
		return
	if not target or not can_attack:
		return
	if attack_hit_box.is_colliding():
		var total_collisions = attack_hit_box.get_collision_count()
		print("total enemy attack collisions: ", total_collisions)
		can_attack = false
		var hit_player := false
		var i = 0
		for collision in range(total_collisions):
			var collidedObject = attack_hit_box.get_collider(i)
			if collidedObject.is_in_group("player") and collidedObject.has_method("take_damage") and not collidedObject.is_dead:
				collidedObject.take_damage(damage)
				print("Ant attacked player for ", damage, " damage!")
			i += 1
		if hit_player:
			animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			attack_sound_3d.play()
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func _chase_target(toChase: Node3D):
	super._chase_target(target)

func become_dead_bug() -> void:
	health_bar_3d.visible = false
	super.become_dead_bug()
	#abdomin.set_surface_override_material(0, DEAD_ANT_MATERIAL)
	should_shrink_on_death = true

func die() -> void:
	animation_tree.set("parameters/Transition/current_state", "dead")
	death_sound_3d.play()
	var collectible = ant_queen_head.instantiate()
	add_sibling(collectible)
	collectible.global_position = global_position
	super.die()

func take_damage(amount: float) -> void:
	hit_sound_3d.play()
	if is_dead:
		return
	health -= amount
	_update()
	print(name, " took ", amount, " damage! Health: ", health)
	if health <= 0:
		die()



func _update() -> void:
	health_bar_3d.value = health
