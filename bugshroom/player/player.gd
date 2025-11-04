extends CharacterBody3D
class_name Player


var speed
const WALK_SPEED = 4.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 6
const SENSITIVITY = 0.005
var gravity = 9.8
@export var player_id = 1
@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5

#health variables
@export var current_health = 100
@export var max_health = 100
@export var health_bar = ProgressBar
var is_dead = false

#stamina variables
@export var max_stamina = 100.0
@export var current_stamina = 100.0
var stamina_drain_rate = 5.0 #stamina drained per second during action
@export var stamina_bar = ProgressBar

#attack variables
@export var attack_range: float = 3.0
@export var attack_damage: float = 25.0
@export var attack_cooldown: float = 0.8
var can_attack: bool = true

#Root Down Mechanic
var is_rooted = false
@export var root_stamina_regen = 15.0 #stamina regained per second while rooted


#fov variables
var base_fov = 75.0
const FOV_CHANGE = 1.5

@onready var animation_player: AnimationPlayer = $PlayerModel/AnimationPlayer
@onready var camera_mount = $CameraMount
@onready var camera_yaw = $CameraMount/CameraYaw
@onready var camera_pitch = $CameraMount/CameraYaw/CameraPitch

#used for making smooth player turning
var last_direction = Vector3.FORWARD
@export var rotation_speed = 3

var current_animation 

func _ready() -> void:
	animation_player.play("player_uncrouch/Armature_002Action")
	if animation_player.current_animation:
		var current_animation = animation_player.current_animation
func _unhandled_input(event):
	#root down input
	if event.is_action_pressed("root_%s" % [player_id]):
		toggle_root()
	if event.is_action_pressed("attack_%s" % [player_id]):
		attack()

func _physics_process(delta):
	if animation_player.animation_changed:
		current_animation = animation_player.current_animation
	
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
		stamina_bar.update()
		speed = SPRINT_SPEED
		animation_player.speed_scale = 2
	else:
		animation_player.speed_scale = 1
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left_%s" % [player_id], "move_right_%s" % [player_id], "move_up_%s" % [player_id], "move_down_%s" % [player_id])
	
	#new vector3 direction taking into account movement inputs and camera rotation
	var direction = (camera_yaw.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if not is_rooted and animation_player.current_animation != "player_uncrouch/Armature_002Action" and !is_dead:
		if direction:
			last_direction = direction
			if animation_player.current_animation != "walk": 
				animation_player.play("walk")
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
			if animation_player.current_animation != "Mushroomdude_Idle_v2/Armature_002|Armature_002Action_001": 
				animation_player.play("Mushroomdude_Idle_v2/Armature_002|Armature_002Action_001")
	else:
		velocity.x = 0 #lerp(velocity.x, direction.x * speed, delta * 4.0)
		velocity.z = 0 #lerp(velocity.z, direction.z * speed, delta * 4.0)
	
	if is_rooted:
		current_stamina += root_stamina_regen * delta
		stamina_bar.update()
	
	$PlayerModel.rotation.y = lerp_angle($PlayerModel.rotation.y, atan2(-last_direction.x, -last_direction.z), delta * rotation_speed)

	move_and_slide()

func attack():
	if not can_attack or is_dead:
		return
	can_attack = false
	print("Player attacking!")

	# Optional animation
	if animation_player.has_animation("attack"):
		animation_player.play("attack")

	# --- FIXED RAYCAST SECTION ---
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

	var from: Vector3 = camera_yaw.global_position
	var to: Vector3 = from + -camera_yaw.transform.basis.z * attack_range

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result: Dictionary = space_state.intersect_ray(query)
	# --- END FIX ---

	if result and result.has("collider"):
		var collider: Node3D = result.collider
		if collider and collider.has_method("take_damage"):
			collider.take_damage(attack_damage)
			print("Hit ", collider.name, " for ", attack_damage, " damage!")

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	
func take_damage(amount):
	current_health -= amount
	health_bar.update()
	if current_health <= 0:
		die()

#Root down toggle function
func toggle_root():
	is_rooted = !is_rooted
	if is_rooted:
		print("Rooting Down")
		animation_player.play("player_crouch/Armature_002Action")
	else:
		animation_player.play("player_uncrouch/Armature_002Action")
		print("Uprooted")
	
func die():
	is_dead = false
