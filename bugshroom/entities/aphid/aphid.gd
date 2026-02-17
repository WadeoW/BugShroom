extends BugBase

@export var aphid_speed: float = 3.0
@export var aphid_health: float = 25.0
@export var bounce_force: float = 14.0

@onready var animation_player: AnimationPlayer = $aphid/AnimationPlayer


func _ready() -> void:
	speed = aphid_speed
	health = aphid_health
	damage = 0.0          # can’t hurt the player
	aggressive = false    # IMPORTANT: no chasing
	add_to_group("aphids")
	animation_player.play("Armature|ArmatureAction")
	super._ready()

func _idle_behavior(delta: float) -> void:
	# Simple random wandering
	wander_timer -= delta
	if wander_timer <= 0.0:
		var angle := randf() * TAU
		wander_direction = Vector3(cos(angle), 0, sin(angle)).normalized()
		wander_timer = wander_interval

	velocity.x = wander_direction.x * wander_speed
	velocity.z = wander_direction.z * wander_speed

# Bouncy damage override
func take_damage(amount: float) -> void:
	if is_dead:
		return

	health -= amount

	# Random bounce direction
	var dir := Vector3(
		(randf() - 1.0) * 2.0,
		0.3,
		(randf() - 1.0) * 2.0
	).normalized()

	velocity = dir * bounce_force

	print(name, " aphid took ", amount, " damage! Health: ", health)
	if health <= 0:
		animation_player.play("aphid_death/aphiddeath")
		die()
