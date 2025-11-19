extends CharacterBody3D
class_name BugBase

# Bug counter to limit total bugs in scene
static var bug_count: int = 0
const MAX_BUGS: int = 15

# Stats
@export var speed: float = 5.0
@export var health: float = 50.0
@export var damage: float = 20.0
@export var detection_range: float = 25.0
@export var despawn_timer: float = 2.0
@export var attack_range: float = 2.0
@export var attack_cooldown: float = 1
@export var aggressive: bool = true
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

#-----------------------------------
# Setup
#-----------------------------------
func _ready():
	# Limit bug count
	if bug_count >= MAX_BUGS:
		queue_free()
		return
	bug_count += 1
	#find closest player
	target = _get_closest_player()

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0
	
	if is_dead:
		return
	#aggressive bugs look for players
	if aggressive:
		target = _get_closest_player()
	else:
		target = null #passive bugs dont chase

	if target:
		var distance = global_position.distance_to(target.global_position)

		# Chase player if within detection range
		if distance <= detection_range:
			is_chasing = true
			_chase_player()
			_try_attack()
		else:
			is_chasing = false
			_idle_behavior(delta)
	else:
		_idle_behavior(delta)

	move_and_slide()
	
func _get_closest_player() -> Node3D:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	var closest = null
	var closest_dist = INF
	for p in players:
		if p and p.is_inside_tree():
			var dist = global_position.distance_to(p.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = p 
	return closest

#-----------------------------------
# Behavior
#-----------------------------------
func _chase_player():
	if not target:
		return
	var direction = (target.global_position - global_position).normalized()
	direction.y = 0
	look_at(target.global_position, Vector3.UP)
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

func _idle_behavior(delta):
	wander_timer -= delta
	if wander_timer <= 0.0:
		var angle = random.randf() * TAU
		wander_direction = Vector3(cos(angle), 0, sin(angle)).normalized()
		wander_timer = wander_interval
	velocity.x = wander_direction.x * wander_speed
	velocity.z = wander_direction.z * wander_speed

func _try_attack():
	if not target or not can_attack:
		return
	var distance = global_position.distance_to(target.global_position)
	if distance <= attack_range:
		can_attack = false
		if target.has_method("take_damage"):
			target.take_damage(damage)
			print("Bug attacked player for ", damage, " damage!")
			await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true


#-----------------------------------
# Damage & Death
#-----------------------------------
func take_damage(amount: float):
	if is_dead:
		return
	health -= amount
	print(name, "took", amount, "damage! Health:", health)
	if health <= 0:
		die()

func die():
	if is_dead:
		return
	is_dead = true
	velocity = Vector3.ZERO
	bug_count -= 1
	await get_tree().create_timer(despawn_timer).timeout
	queue_free()
