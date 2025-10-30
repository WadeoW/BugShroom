extends CharacterBody3D
class_name Player

var speed
const WALK_SPEED = 4.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005
var gravity = 9.8
@export var player_id = 1
@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5


#stamina variables
@export var max_stamina = 100.0
@export var current_stamina = 100.0
var stamina_drain_rate = 5.0 #stamina drained per second during action

#fov variables
var base_fov = 75.0
const FOV_CHANGE = 1.5

@onready var camera_mount = $CameraMount



func _physics_process(delta):
	# add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

#allows you to hit the escape key to get mouse cursor back
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# handle jump
	if Input.is_action_just_pressed("jump_%s" % [player_id]) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# handle sprint
	if Input.is_action_pressed("sprint_%s" % [player_id]) and current_stamina > 0:
		current_stamina -= stamina_drain_rate * delta
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left_%s" % [player_id], "move_right_%s" % [player_id], "move_up_%s" % [player_id], "move_down_%s" % [player_id])
	var camera_basis = camera_mount.global_transform.basis
	
	#new vector3 direction taking into account movement inputs and camera rotation
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
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


	move_and_slide()
