extends CharacterBody3D
class_name BugBase

#bug counter
static var bug_count: int = 0
const MAX_BUGS: int = 3

@export var speed: float = 5.0
@export var health: float = 50.0
@export var damage: float = 20.0
@export var detection_range: float = 50.0
@export var despawn_timer: float = 2.0
@export var attack_range: float = 2.0
@export var attack_cooldown: float = 1.5
var can_attack: bool = true

#wandering variables
@export var wander_interval: float = 3.0
@export var wander_speed: float = 2.0
var wander_direction: Vector3 = Vector3.ZERO
var wander_timer: float = 0.0
var random := RandomNumberGenerator.new()

var target: Node3D = null
var is_dead: bool = false
var is_chasing: bool = false

func _ready():
	#limit bugs
	if bug_count >= MAX_BUGS:
		queue_free()
		return
	
	bug_count += 1
	target = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	# gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0
	
	if is_dead:
		return
	
	if target:
		var distance = global_position.distance_to(target.global_position)
		
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

# Behavior

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
		print("Bug attacked the player!") #for now prints to console
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true


# Damage and Death

func take_damage(amount: float):
	if is_dead:
		return
	health -= amount
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
		
	
