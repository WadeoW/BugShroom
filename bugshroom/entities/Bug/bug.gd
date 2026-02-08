extends CharacterBody3D
class_name BugBase

# Bug counter to limit total bugs in scene
static var bug_count: int = 0
#var MAX_BUGS: int = 15

# Stats
@export var speed: float = 5.0
@export var rotationSpeed: float = 1.5
@export var health: float = 50.0
@export var damage: float = 20.0
@export var bug_nutrient_value: float = 50.0 #how much nutrients the base will gain upon killing bug
@export var detection_range: float = 40.0 #how far away the bug can detect players
@export var despawn_timer: float = 1.0
@export var attack_range: float = 2.3
@export var attack_cooldown: float = 1.0
@export var aggressive: bool = true   # ← ants / beetles true, aphids false
@export var territorial: bool = false # beetles, attack other bugs when they are close
var can_attack: bool = true

# Wandering / idle variables
@export var wander_interval: float = 3.0
@export var wander_speed: float = 2.0
var wander_direction: Vector3 = Vector3.ZERO
var wander_timer: float = 0.0
var random := RandomNumberGenerator.new()

# State variables
var target: Node3D = null
var is_dead: bool = false
var is_chasing: bool = false
var is_chasing_bug: bool = false
var is_trapped: bool = false

# Other
var knockback: Vector2 = Vector2.ZERO
@onready var attack_hit_box = get_node_or_null("AttackHitBox")


#-----------------------------------
# Setup
#-----------------------------------
func _ready():
	target = _get_closest_in_group("player")

#-----------------------------------
# Main loop
#-----------------------------------
func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	# Manually get rid of knockback over time
	knockback = knockback.move_toward(Vector2.ZERO, 20 * delta)

	if is_dead:
		return

	# Only aggressive bugs look for players
	if aggressive:
		target = _get_closest_in_group("player")
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

	if territorial and !is_chasing:
		var closest_bug = _get_closest_in_group("bug")
		var distance := global_position.distance_to(closest_bug.global_position)
		if distance <= detection_range * 0.5:
			is_chasing_bug = true
			_chase_target(closest_bug)
			_try_attack()
		else:
			is_chasing_bug = false
	
	# always rotate towards the current direction they are moving towards subtracting knockback
	var velocityDirection := velocity.normalized() - Vector3(knockback.x, 0, knockback.y)
	velocityDirection.y = 0.0
	if velocityDirection.length() > 0.001:
		var targetDirection := atan2(velocityDirection.x, velocityDirection.z) + PI
		rotation.y = lerp_angle(rotation.y, targetDirection, rotationSpeed * delta)
	
	move_and_slide()

func _get_closest_in_group(group: String ) -> Node3D:
	var nodes := get_tree().get_nodes_in_group(group)
	if nodes.is_empty():
		return null

	var closest: Node3D = null
	var closest_dist := INF

	for n in nodes:
		if n and n.is_inside_tree() and self != n:
			var node := n as Node3D
			var dist := global_position.distance_to(node.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = node
	return closest

#-----------------------------------
# Behavior
#-----------------------------------
func _chase_target(node: Node3D) -> void:
	if not node:
		return
	var direction := (node.global_position - global_position).normalized()
	direction.y = 0
	if not is_trapped and (position - node.position).length() > 0.1:
		velocity.x = direction.x * speed + knockback.x
		velocity.z = direction.z * speed + knockback.y
	else:
		velocity = Vector3.ZERO

func _idle_behavior(delta: float) -> void:
	wander_timer -= delta
	if wander_timer <= 0.0:
		var angle := random.randf() * TAU
		wander_direction = Vector3(cos(angle), 0, sin(angle)).normalized()
		wander_timer = wander_interval

	if not is_trapped:
		velocity.x = wander_direction.x * wander_speed + knockback.x
		velocity.z = wander_direction.z * wander_speed + knockback.y

func _try_attack() -> void:
	if not aggressive:
		return
	if not target or not can_attack:
		return
	if attack_hit_box.is_colliding():
		var total_collisions = attack_hit_box.get_collision_count()
		print("total enemy attack collisions: ", total_collisions)
		can_attack = false
		var i = 0
		for collision in range(total_collisions):
			var collidedObject = attack_hit_box.get_collider(i)
			if collidedObject.is_in_group("player") and target.has_method("take_damage") and not target.is_dead:
				collidedObject.take_damage(damage)
				print("Bug attacked player for ", damage, " damage!")
			i += 1
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

#-----------------------------------
# Damage & Death
#-----------------------------------
func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= amount
	print(name, " took ", amount, " damage! Health: ", health)
	if health <= 0:
		die()

func apply_knockback(direction: Vector3, force: float):
	knockback += Vector2(direction.x, direction.z).normalized() * force
	velocity.y += direction.normalized().y * force

func become_dead_bug() -> void:
	add_to_group("dead_bug")

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector3.ZERO
	bug_count -= 1
	SignalBus.emit_signal("bug_died")
	# Main.current_colony_nutrients += bug_nutrient_value
	if is_in_group("ants") and random.randf() > 0.5:
		#become_dead_bug()
		await get_tree().create_timer(despawn_timer).timeout
		queue_free()
	else:
		await get_tree().create_timer(despawn_timer).timeout
		queue_free()
