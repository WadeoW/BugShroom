extends CharacterBody3D
class_name Player

@onready var head = $Head
@onready var camera = $Head/Camera3D
var speed
const WALK_SPEED = 4.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005
var gravity = 9.8

#stamina variables
@export var max_stamina = 100.0
@export var current_stamina = 100.0
var stamina_drain_rate = 5.0 #stamina drained per second during action

# health variables
@export var max_health: float = 100.0
var current_health: float = max_health

# attack variables
@export var attack_damage: float = 25.0
@export var attack_range: float = 3.0
@export var attack_cooldown: float = 1.0
var can_attack: bool = true


#Root Down Mechanic
var is_rooted = false
@export var root_stamina_regen = 15.0 #stamina regained per second while rooted

#bob variables
const BOB_FREQ = 3.0
const BOB_AMP = 0.04
var t_bob = 0.0

#fov variables
var base_fov = 75.0
const FOV_CHANGE = 1.5


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion: #how the player turns and looks around
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(80))
	#root down input
	if event is InputEventKey and event.is_pressed() and event.scancode == KEY_R:
		toggle_root()
	if event.is_action_pressed("attack") and can_attack:
		perform_attack()


func _physics_process(delta):
	# add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

#allows you to hit the escape key to get mouse cursor back
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		

# handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# handle sprint
	if Input.is_action_pressed("sprint") and current_stamina > 0:
		current_stamina -= stamina_drain_rate * delta
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if not is_rooted:
		if is_on_floor():
			if direction:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
				velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 4.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 4.0)
	else:
		#stop movement when rooted
		velocity.x = 0
		velocity.z = 0
	#stamina regeneration
	if is_rooted:
		current_stamina = clamp(current_stamina + root_stamina_regen * delta, 0, max_stamina)

	#head bob 
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = base_fov + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

#Root down toggle function
func toggle_root():
	is_rooted = !is_rooted
	if is_rooted:
		print("Rooting Down")
	else:
		print("Uprooted")

func perform_attack():
	can_attack = false
	#raycast forward from camera to detect hit
	var from = camera.global_position
	var to = from + -camera.global_transform.basis.z * attack_range
	
	var space_state = get_world_3d().physics_direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result and result.has("collider"):
		var hit_object = result.collider
		if hit_object.has_method("take_damage"):
			hit_object.take_damage(attack_damage)
			print("Player attacked", hit_object.name, "for", attack_damage, "damage")
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func take_damage(amount: float):
	current_health -= amount
	print("player health:", current_health)
	if current_health <= 0:
		die()
func die():
	print("Player has died")
	

	
	
