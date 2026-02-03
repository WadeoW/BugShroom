extends CharacterBody3D
class_name Puffball

signal player_death

# Movement variables
var inputVelocity: Vector2 = Vector2.ZERO
const ACCELERATION = 7
const DIRECTIONAL_ACCELERATION: float = 2.0
const MAX_SPEED = 12.0
const JUMP_VELOCITY = 6
const SENSITIVITY = 0.005
var gravity = 9.8
var knockback: Vector2 = Vector2.ZERO
const MAX_KNOCKBACK_SPEED = 20
@export var player_id: int = 1
@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5
var direction

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
const ROLLING_ATTACK_DAMAGE: float = 5.0 # this is multiplied by speed in xz plane
const MIN_ROLLING_SPEED_FOR_ATTACK: float = 5.0
const MIN_ROLLING_SPEED_FOR_TERRAIN_BOUNCE: float = 8.0
const TERRAIN_BOUNCE_BACK: float = 0.5 # multiplied by incoming speed and sends you in opposite direction from what you hit
const BUG_KB = 10
const SELF_KB_ON_BEETLE = 10
const OTHER_PLAYER_KB = 7

#sprint charge variables
var chargeVector: Vector2 = Vector2.ZERO
const CHARGE_SPEED = 15
@onready var charge_duration: Timer = $ChargeDuration
@onready var charge_cooldown: Timer = $ChargeCooldown

#ability and class variables
var ability_active = false
@onready var ability_type = load("res://entities/abilities/SporeCloud.tscn")
var mushroom_type = PlayerData.MushroomType.Puffball
@export var char_model: PackedScene

#Root Down Mechanic
var is_rooted = false
@export var root_stamina_regen = 15.0 #stamina regained per second while rooted

@onready var animation_player: AnimationPlayer = $CharacterModel/AnimationPlayer

@onready var camera_mount = $CameraMount
@onready var camera_yaw = $CameraMount/CameraYaw
@onready var camera_pitch = $CameraMount/CameraYaw/CameraPitch

#used for making smooth player turning
var last_direction = Vector3.FORWARD
@export var rotation_speed = 5

var current_animation: String = ""

func _ready() -> void:
	animation_player.play("puffmushroom_animations/roll")
	var current_animation = animation_player.current_animation
	
	#class selection and ability loading
	if player_id == 1:
		mushroom_type = PlayerData.p1_mushroom_type
	#debug
		print("p1 mushroom type :", mushroom_type)
	elif player_id == 2:
		mushroom_type = PlayerData.p2_mushroom_type
		print("player 2 mushroom type:", PlayerData.p2_mushroom_type)
	
	#set up health and stamina bars
	health_bar.max_value = max_health
	stamina_bar.max_value = max_stamina
	health_bar.value = health_bar.max_value
	stamina_bar.value = stamina_bar.max_value
	
	

func update() -> void:
	health_bar.value = current_health
	stamina_bar.value = current_stamina 
	
func _unhandled_input(event):
	#root down input
	if event.is_action_pressed("root_%s" % [player_id]):
		toggle_root()
		
	if event.is_action_pressed("interact_%s" % [player_id]) and ability_active == false and is_on_floor():
		cast_ability()	
		if ability_active:
			print("abilty active = true")
		else:
			print("ability active = false")

func _physics_process(delta):
	if animation_player.animation_changed:
		current_animation = animation_player.current_animation
	
	# add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# knockback and charging speed decay
	knockback = knockback.move_toward(Vector2.ZERO, 20 * delta)
	chargeVector = chargeVector.move_toward(Vector2.ZERO, 20 * delta)
	if is_dead:
		knockback = Vector2.ZERO
		chargeVector = Vector2.ZERO
	
	# handle jump
	if Input.is_action_just_pressed("jump_%s" % [player_id]) and is_on_floor() and !is_rooted and current_stamina > 0:
		velocity.y = JUMP_VELOCITY

	# handle sprint/charge attack
	if Input.is_action_just_pressed("sprint_%s" % [player_id]) and charge_cooldown.is_stopped():
		charge_attack()
		inputVelocity = Vector2.ZERO
	if charge_duration.time_left > 0:
		velocity = Vector3(0, velocity.y, 0)
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left_%s" % [player_id], "move_right_%s" % [player_id], "move_up_%s" % [player_id], "move_down_%s" % [player_id])
	
	#new vector3 direction taking into account movement inputs and camera rotation
	direction = (camera_yaw.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if not is_rooted  and !is_dead:
		if direction:
			last_direction = direction
			if animation_player.current_animation != "puffmushroom_animations/roll" and animation_player.current_animation != "ability_use" and animation_player.current_animation != "take_damage": 
				animation_player.play("puffmushroom_animations/roll")

			# play rolling animation based on speed, at max speed the animation is played at 4x speed
			animation_player.speed_scale = Vector2(velocity.x, velocity.z).length() / (MAX_SPEED * 0.25)
	# directionalAcceleration gets the dot product of the input direction and current velocity direction. 
	# It will increases as you face further away from the current direction you are going which makes changing direction faster
	# You accelerate DIRECTIONAL_ACCELERATION times faster when you are accelerating the opposite direction you are going
			var directionalAcceleration = 1 - clampf(Vector2(direction.x, direction.z).normalized().dot(Vector2(velocity.x, velocity.z).normalized()), -1, 0) * (DIRECTIONAL_ACCELERATION - 1)
			velocity.x += direction.x * ACCELERATION * directionalAcceleration * delta
			velocity.z += direction.z * ACCELERATION * directionalAcceleration * delta
		else:
			velocity.x = lerp(velocity.x, direction.x, delta * 3.0)
			velocity.z = lerp(velocity.z, direction.z, delta * 3.0)
			#if !animation_player.is_playing():
				#animation_player.play("Mushroomdude_Idle_v2/Armature_002|Armature_002Action_001")
	else:
		animation_player.speed_scale = 1
		velocity.x = 0
		velocity.z = 0 
	# clamping the x and z speed so the horizontal velocity doesnt exceed MAX_SPEED
	var clampedVelocity = Vector2(velocity.x, velocity.z).limit_length(MAX_SPEED)
	var clampedKnockback = knockback.limit_length(MAX_KNOCKBACK_SPEED)
	if charge_duration.time_left == 0:
		velocity = Vector3(clampedVelocity.x, velocity.y, clampedVelocity.y) + Vector3(clampedKnockback.x, 0, clampedKnockback.y) + Vector3(chargeVector.x, 0, chargeVector.y)

	if is_rooted:
		if current_stamina <= max_stamina:
			current_stamina += root_stamina_regen * delta
		update()
	
	$CharacterModel.rotation.y = lerp_angle($CharacterModel.rotation.y, atan2(-last_direction.x, -last_direction.z), delta * rotation_speed)
	
	move_and_slide()

	
func take_damage(amount):
	animation_player.play("take_damage")
	current_health -= amount
	update()
	if current_health <= 0 and !is_dead:
		die()
		
func heal(amount):
	if current_health < max_health:
		current_health += amount
	update()
	
#Root down toggle function
func toggle_root():
	is_rooted = !is_rooted
	if is_rooted:
		print("Rooting Down")
		animation_player.play("puffmushroom_animations/squash")
	else:
		animation_player.play("puffmushroom_animations/unsquash")
		print("Uprooted")

# area contact with enemies for speed based damage and knockback
func _on_area_3d_body_entered(body: Node3D) -> void:
	var kb_direction: Vector2
	kb_direction.x = body.position.x - position.x
	kb_direction.y = body.position.z - position.z
	kb_direction = kb_direction.normalized()
	var speed = Vector2(velocity.x, velocity.z).length()
	if body.is_in_group("bug") and speed > MIN_ROLLING_SPEED_FOR_ATTACK:
		if body.is_in_group("ants") or body.is_in_group("aphids"):
			add_collision_exception_with(body)
			body.apply_knockback(Vector3(kb_direction.x, 1, kb_direction.y), BUG_KB)
		if body.is_in_group("beetles"):
			apply_knockback(Vector3(-kb_direction.x, 2, -kb_direction.y), SELF_KB_ON_BEETLE)
		var rollDamage = clampf(Vector2(velocity.x, velocity.z).length() * ROLLING_ATTACK_DAMAGE, 10, 100)
		body.take_damage(rollDamage)
		print(body.name, " took ", rollDamage, " rolling damage")
		return
	if body.is_in_group("player"):
		# only make the slower one take knockback
		var otherPlayerSpeed = Vector2(body.velocity.x, body.velocity.z).length()
		var thisPlayerSpeed = Vector2(velocity.x, velocity.z).length()
		if otherPlayerSpeed < thisPlayerSpeed:
			body.apply_knockback(Vector3(kb_direction.x, 1, kb_direction.y), OTHER_PLAYER_KB)
		return
	# terrain collision, not working with logs
	if body.name != "floor" and speed > MIN_ROLLING_SPEED_FOR_TERRAIN_BOUNCE:
		apply_knockback(Vector3(-kb_direction.x, 2, -kb_direction.y), Vector2(velocity.x, velocity.z).length() * TERRAIN_BOUNCE_BACK)

func cast_ability():
	animation_player.play("ability_use")
	ability_active = true
	var spawn = load("res://entities/abilities/SporeCloud.tscn").instantiate()
	add_sibling(spawn)
	print("ability has been cast")

func charge_attack():
	print("charge attack")
	charge_cooldown.start()
	charge_duration.start()

func _on_charge_duration_timeout() -> void:
	chargeVector = Vector2(direction.x, direction.z) * CHARGE_SPEED

func apply_knockback(direction: Vector3, force: float):
	knockback += Vector2(direction.x, direction.z).normalized() * force
	velocity.y += direction.normalized().y * force
	
func die():
	cast_ability()
	is_dead = true
	print("Player", player_id, "has died!")
	#animation_player.play("die")
	set_physics_process(false)
	SignalBus.player_died.emit()
	
	await get_tree().create_timer(respawn_delay).timeout
	respawn()
	
func respawn():
	is_dead = false
	knockback = Vector2.ZERO; velocity = Vector3.ZERO; chargeVector = Vector2.ZERO
	#animation_player.play("Mushroomdude_Idle_v2/Armature_002|Armature_002Action_001")
	global_position = Vector3(5, 1, 5)
	print("player", player_id, "respawned!")
	current_health = max_health
	update()
	current_stamina = max_stamina
	update()
	set_physics_process(true)
