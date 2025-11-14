extends CharacterBody3D
class_name Player

signal player_death

var speed
const WALK_SPEED = 4.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 6
const SENSITIVITY = 0.005
var gravity = 9.8
@export var player_id = 1
@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5

#respawn
@export var respawn_delay: float = 5.0

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
@export var attack_damage: float = 10.0
var can_attack: bool = true
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var attack_hit_box: ShapeCast3D = $AttackHitBox

#Root Down Mechanic
var is_rooted = false
@export var root_stamina_regen = 15.0 #stamina regained per second while rooted



#fov variables
var base_fov = 75.0
const FOV_CHANGE = 1.5

@onready var animation_tree : AnimationTree = $PlayerModel/AnimationTree
@onready var animation_player: AnimationPlayer = $PlayerModel/AnimationPlayer
@onready var camera_mount = $CameraMount
@onready var camera_yaw = $CameraMount/CameraYaw
@onready var camera_pitch = $CameraMount/CameraYaw/CameraPitch

@onready var root_state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/JumpStateMachine/playback")

#used for making smooth player turning
var last_direction = Vector3.FORWARD
@export var rotation_speed = 3

var walk_value = 0
var run_value = 1
var blend_speed = 15
#var current_animation 

func _ready() -> void:
	animation_tree.set("parameters/BlendSpace1D/blend_position", 0)
	#var current_animation = animation_player.current_animation
	
	
func _unhandled_input(event):
	#root down input
	if event.is_action_pressed("root_%s" % [player_id]):
		toggle_root()
		

func _physics_process(delta):
	#if animation_player.animation_changed:
		#current_animation = animation_player.current_animation
	
	# add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta


# handle jump
	if Input.is_action_just_pressed("jump_%s" % [player_id]) and is_on_floor() and !is_rooted and current_stamina > 0:
		velocity.y = JUMP_VELOCITY
		animation_tree["parameters/oneshot_jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		


	if Input.is_action_just_pressed("attack_%s" % [player_id]) and attack_cooldown.is_stopped():
		attack()
		

	# handle sprint
	if Input.is_action_pressed("sprint_%s" % [player_id]) and current_stamina > 0:
		current_stamina -= stamina_drain_rate * delta
		stamina_bar.update()
		speed = SPRINT_SPEED
		animation_tree.set("parameters/TimeScale/scale", 2)
		#if animation_player.current_animation == "walkanimation":
			#animation_player.speed_scale = 2
	else:
		#animation_player.speed_scale = 1
		animation_tree.set("parameters/TimeScale/scale", 1)
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left_%s" % [player_id], "move_right_%s" % [player_id], "move_up_%s" % [player_id], "move_down_%s" % [player_id])
	
	#new vector3 direction taking into account movement inputs and camera rotation
	var direction = (camera_yaw.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if not is_rooted and !is_dead:
		if direction:
			last_direction = direction
			if is_on_floor() and !is_rooted and !is_dead:
				animation_tree["parameters/BlendSpace1D/blend_position"] = 1 #lerpf(0, 1, blend_speed * delta)
			#if animation_player.current_animation != "walkanimation" and animation_player.current_animation != "mushroomdude_allanimations2/attack": 
				#animation_player.play("walkanimation")
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
			
			#if animation_player.current_animation != "Mushroomdude_Idle_v2/Armature_002|Armature_002Action_001" and animation_player.current_animation != "take_damage": 
			#if !animation_player.is_playing():
				#animation_player.play("Mushroomdude_Idle_v2/Armature_002|Armature_002Action_001")
	else:
		velocity.x = 0
		velocity.z = 0 
		
	animation_tree["parameters/BlendSpace1D/blend_position"] = 0 #lerpf(1, 0, blend_speed * delta)
	
	if is_rooted:
		current_stamina += root_stamina_regen * delta
		stamina_bar.update()
	
	$PlayerModel.rotation.y = lerp_angle($PlayerModel.rotation.y, atan2(-last_direction.x, -last_direction.z), delta * rotation_speed)

	move_and_slide()

	
func take_damage(amount):
	animation_tree["parameters/oneshot_take_damage/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	current_health -= amount
	health_bar.update()
	if current_health <= 0 and !is_dead:
		die()

#Root down toggle function
func toggle_root():
	is_rooted = !is_rooted
	
	if is_rooted:
		animation_tree["parameters/Oneshot_Crouch/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		#animation_player.play("mushroomdude_allanimations2/crouch")
		
	else:
		animation_tree["parameters/Oneshot_Crouch/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		#animation_tree.set("parameters/Transition/transition_request", "uncrouch")
		#animation_tree["parameters/oneshot_crouching/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func attack():
	animation_tree["parameters/oneshot_attack/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	can_attack = false
	attack_cooldown.start()
	if attack_hit_box.is_colliding():
		var total_collisions = attack_hit_box.get_collision_count()
		for i in total_collisions:
			if attack_hit_box.get_collider(i).has_method("take_damage"):
				attack_hit_box.get_collider(i).take_damage(attack_damage)
	
func die():
	is_dead = true
	print("Player", player_id, "has died!")
	animation_tree["parameters/oneshot_death/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	set_physics_process(false)
	SignalBus.player_died.emit()
	
	await get_tree().create_timer(respawn_delay).timeout
	respawn()
	
func respawn():
	is_dead = false
	global_position = Vector3(5, 1, 5)
	print("player", player_id, "respawned!")
	current_health = max_health
	health_bar.update()
	current_stamina = max_stamina
	stamina_bar.update()
	set_physics_process(true)
	
	
