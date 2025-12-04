extends BugBase

@export var ant_speed: float = 5.0
@export var ant_health: float = 50.0
@export var ant_damage: float = 10.0
@export var ally_alert_radius: float = 10.0

var has_alerted_allies: bool = false

func _ready():
	speed = ant_speed
	health = ant_health
	damage = ant_damage
	aggressive = true
	add_to_group("ants")
	add_to_group("bug")
	super._ready()

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
