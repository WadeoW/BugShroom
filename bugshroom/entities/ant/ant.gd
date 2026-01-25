extends BugBase

@export var ant_speed: float = 5.0
@export var ant_health: float = 100.0
@export var ant_damage: float = 10.0
@export var ally_alert_radius: float = 10.0
@onready var animation_player: AnimationPlayer = $ant/AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var anim_state = animation_tree.get("parameters/playback")
var has_alerted_allies: bool = false


func _ready():
	speed = ant_speed
	health = ant_health
	damage = ant_damage
	aggressive = true
	add_to_group("ants")
	add_to_group("bug")
	super._ready()
	#animation_player.play("walk")
	animation_tree.active = true

func _try_attack() -> void:
	if not aggressive:
		return
	if not target or not can_attack:
		return

	var distance := global_position.distance_to(target.global_position)
	if distance <= attack_range:
		anim_state.travel("ant_animations_attack")
		can_attack = false
		if target.has_method("take_damage") and not target.is_dead:
			target.take_damage(damage)
			print("Bug attacked player for ", damage, " damage!")
			await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func _idle_behavior(delta):
	has_alerted_allies = false
	var forward = -transform.basis.z
	forward.y = 0
	forward = forward.normalized()
	velocity.x = forward.x * wander_speed
	velocity.z = forward.z * wander_speed

func _chase_player():
	if target and not has_alerted_allies:
		has_alerted_allies = true
		_alert_ants_nearby()
	super._chase_player()

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

func die() -> void:
	animation_tree.set("parameters/conditions/is_dead", true)
	super.die()
	
