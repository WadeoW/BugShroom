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

@onready var camera_mount: Node3D = $CameraMount

#bob variables
#const BOB_FREQ = 3.0
#const BOB_AMP = 0.04
#var t_bob = 0.0

#fov variables
var base_fov = 75.0
const FOV_CHANGE = 1.5


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#func _unhandled_input(event):
	#if event is InputEventMouseMotion: #how the player turns and looks around
		#head.rotate_y(-event.relative.x * SENSITIVITY)
		#camera.rotate_x(-event.relative.y * SENSITIVITY)
		#camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(80))

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-80), deg_to_rad(60))


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

	#head bob 
	#t_bob += delta * velocity.length() * float(is_on_floor())
	#camera.transform.origin = _headbob(t_bob)
#
	#var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	#var target_fov = base_fov + FOV_CHANGE * velocity_clamped
	#camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	move_and_slide()

#func _headbob(time) -> Vector3:
	#var pos = Vector3.ZERO
	#pos.y = sin(time * BOB_FREQ) * BOB_AMP
	#pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	#return pos
