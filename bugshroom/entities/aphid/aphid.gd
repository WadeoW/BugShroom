extends BugBase
@export var aphid_speed: float = 3.0
@export var aphid_health: float = 10.0
@export var bounce_force: float = 14.0

func _ready():
	speed = aphid_speed
	health = aphid_health
	damage = 0.0
	aggressive = false
	add_to_group("aphids")
	
	super._ready()
	
func _idle_behavior(delta):
	wander_timer -= delta
	if wander_timer <= 0.0:
		var angle = randf() * TAU
		wander_direction = Vector3(cos(angle), 0, sin(angle)).normalized()
		wander_timer = wander_interval
		
	velocity.x = wander_direction.x * wander_speed
	velocity.z = wander_direction.z * wander_speed
	
#bouncy damage
func take_damage(amount: float):
	if is_dead:
		return
		
	health -= amount
	
	#random bounce direction
	var dir = Vector3(
		randf() * 2.0 - 1.0,
		1.0,
		randf() * 2.0 - 1.0
	).normalized()
	
	velocity = dir * bounce_force
	
	print(name, "aphid took", amount, "damage! Health:", health)
	if health <= 0:
		die()
