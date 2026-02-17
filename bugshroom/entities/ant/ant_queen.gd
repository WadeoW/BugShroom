extends BugBase

@export var ant_speed: float = 5.0
@export var ant_health: float = 1000.0
@export var ant_damage: float = 80.0
@export var ally_alert_radius: float = 100.0

var has_alerted_allies: bool = false


#sound variables
@onready var hit_sound_3d: AudioStreamPlayer3D = $Audio/HitSound3D
@onready var walk_sound_3d: AudioStreamPlayer3D = $Audio/WalkSound3D
@onready var death_sound_3d: AudioStreamPlayer3D = $Audio/DeathSound3D
@onready var attack_sound_3d: AudioStreamPlayer3D = $Audio/AttackSound3D

#healthbar variables
@onready var health_bar_3d: ProgressBar = $SubViewport/HealthBar3D


func _ready():
	speed = ant_speed
	health = ant_health
	damage = ant_damage
	aggressive = true
	scavenger = true
	add_to_group("ants")
	add_to_group("bug")
	super._ready()

	health_bar_3d.max_value = ant_health
	health_bar_3d.value = ant_health
	
	
	

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
			#anim_state.travel("ant_animations_attack")
			attack_sound_3d.play()
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func _idle_behavior(delta):
	has_alerted_allies = false
	super._idle_behavior(delta)

func _chase_target(toChase: Node3D):
	if target and not has_alerted_allies:
		has_alerted_allies = true
		_alert_ants_nearby()
	super._chase_target(target)

func _alert_ants_nearby():
	var ants = get_tree().get_nodes_in_group("ants")
	for a in ants:
		if a == self:
			continue
		if not a or not a.is_inside_tree():
			continue
		if not (a is BugBase):
			continue
		
		var dist = global_position.distance_to(a.global_position)
		if dist <= ally_alert_radius:
			a.target = target
			a.is_chasing = true

func become_dead_bug() -> void:
	health_bar_3d.visible = false
	super.become_dead_bug()
	#abdomin.set_surface_override_material(0, DEAD_ANT_MATERIAL)
	should_shrink_on_death = true

func die() -> void:
	#animation_tree.set("parameters/conditions/is_dead", true)
	death_sound_3d.play()
	super.die()

func take_damage(amount: float) -> void:
	hit_sound_3d.play()
	#anim_state.travel("take_damage")
	if is_dead:
		return
	health -= amount
	_update()
	print(name, " took ", amount, " damage! Health: ", health)
	if health <= 0:
		die()



func _update() -> void:
	health_bar_3d.value = health
