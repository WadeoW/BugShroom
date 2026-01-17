extends CharacterBody3D
class_name BugBase

# Bug counter to limit total bugs in scene
static var bug_count: int = 0
#var MAX_BUGS: int = 15

# Stats
@export var speed: float = 5.0
@export var health: float = 50.0
@export var damage: float = 20.0
@export var bug_nutrient_value: float = 50.0
@export var detection_range: float = 40.0
@export var despawn_timer: float = 1.0
@export var attack_range: float = 2.3
@export var attack_cooldown: float = 1.0
@export var aggressive: bool = true   # ← ants / beetles true, aphids false
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
var is_trapped: bool = false

#-----------------------------------
# Setup
#-----------------------------------
func _ready():
	# Limit bug count
	#if bug_count >= MAX_BUGS:
		#queue_free()
		#return
	#bug_count += 1
	
	target = _get_closest_player()

#-----------------------------------
# Main loop
#-----------------------------------
func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0

	if is_dead:
		return

	# Only aggressive bugs look for players
	if aggressive:
		target = _get_closest_player()
	else:
		target = null  # passive bugs don't chase at all

	if aggressive and target:
		var distance := global_position.distance_to(target.global_position)

		# Chase player if within detection range
		if distance <= detection_range:
			is_chasing = true
			_chase_player()
			_try_attack()
		else:
			is_chasing = false
			_idle_behavior(delta)
	else:
		# Passive bugs or no target: just wander
		is_chasing = false
		_idle_behavior(delta)

	move_and_slide()

func _get_closest_player() -> Node3D:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null

	var closest: Node3D = null
	var closest_dist := INF

	for p in players:
		if p and p.is_inside_tree():
			var node := p as Node3D
			var dist := global_position.distance_to(node.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = node

	return closest

#-----------------------------------
# Behavior
#-----------------------------------
func _chase_player() -> void:
	if not target:
		return
	var direction := (target.global_position - global_position).normalized()
	direction.y = 0
	look_at(target.global_position, Vector3.UP)
	rotation.x = 0
	rotation.z = 0
	if not is_trapped and (position - target.position).length() > 0.1:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity = Vector3.ZERO

func _idle_behavior(delta: float) -> void:
	wander_timer -= delta
	if wander_timer <= 0.0:
		var angle := random.randf() * TAU
		wander_direction = Vector3(cos(angle), 0, sin(angle)).normalized()
		wander_timer = wander_interval

	if not is_trapped:
		velocity.x = wander_direction.x * wander_speed
		velocity.z = wander_direction.z * wander_speed

func _try_attack() -> void:
	if not aggressive:
		return
	if not target or not can_attack:
		return

	var distance := global_position.distance_to(target.global_position)
	if distance <= attack_range:
		can_attack = false
		if target.has_method("take_damage") and not target.is_dead:
			target.take_damage(damage)
			print("Bug attacked player for ", damage, " damage!")
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

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector3.ZERO
	bug_count -= 1
	SignalBus.emit_signal("bug_died")
	# Main.current_colony_nutrients += bug_nutrient_value
	await get_tree().create_timer(despawn_timer).timeout
	queue_free()
