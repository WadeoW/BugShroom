extends CharacterBody3D
class_name Puffball

signal player_death

var speed
var WALK_SPEED = 6.0
var SPRINT_SPEED = 10.0
const ACCELERATION = 7
const MAX_SPEED = 12.0
const JUMP_VELOCITY = 6
const SENSITIVITY = 0.005
var gravity = 9.8
@export var player_id: int = 1
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
@export var attack_damage: float = 20.0
const ROLLING_ATTACK_DAMAGE: float = 5.0 # this is multiplied by speed in xz plane
const MIN_ROLLING_SPEED_FOR_ATTACK: float = 5.0
var can_attack: bool = true
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var attack_hit_box: ShapeCast3D = $AttackHitBox


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
	animation_player.play("roll")
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


# handle jump
	if Input.is_action_just_pressed("jump_%s" % [player_id]) and is_on_floor() and !is_rooted and current_stamina > 0:
		velocity.y = JUMP_VELOCITY

#handle attack
	if Input.is_action_just_pressed("attack_%s" % [player_id]) and attack_cooldown.is_stopped():
		attack()
		

	# handle sprint
	if Input.is_action_pressed("sprint_%s" % [player_id]) and current_stamina > 0:
		current_stamina -= stamina_drain_rate * delta
		update()
		speed = SPRINT_SPEED
		if animation_player.current_animation == "roll":
			animation_player.speed_scale = 2
	else:
		animation_player.speed_scale = 1
		speed = WALK_SPEED
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left_%s" % [player_id], "move_right_%s" % [player_id], "move_up_%s" % [player_id], "move_down_%s" % [player_id])
	
	#new vector3 direction taking into account movement inputs and camera rotation
	var direction = (camera_yaw.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if not is_rooted  and !is_dead:
		if direction:
			last_direction = direction
			if animation_player.current_animation != "roll" and animation_player.current_animation != "ability_use" and animation_player.current_animation != "take_damage": 
				animation_player.play("roll")

			# play rolling animation based on speed, at max speed the animation is played at 4x speed
			animation_player.speed_scale = Vector2(velocity.x, velocity.z).length() / (MAX_SPEED * 0.25)

			velocity.x += direction.x * ACCELERATION * delta
			velocity.z += direction.z * ACCELERATION * delta
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
			#if !animation_player.is_playing():
				#animation_player.play("Mushroomdude_Idle_v2/Armature_002|Armature_002Action_001")
	else:
		animation_player.speed_scale = 1
		velocity.x = 0
		velocity.z = 0 
	
	# clamping the x and z speed so the horizontal velocity doesnt exceed MAX_SPEED
	var clampedVelocity = Vector2(velocity.x, velocity.z).limit_length(MAX_SPEED)
	velocity = Vector3(clampedVelocity.x, velocity.y, clampedVelocity.y)
	
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
		animation_player.play("crouch")
	else:
		animation_player.play("uncrouch")
		print("Uprooted")

func attack():
	#animation_player.play("mushroomdude_allanimations2/attack")
	can_attack = false
	attack_cooldown.start()
	if attack_hit_box.is_colliding():
		var total_collisions = attack_hit_box.get_collision_count()
		print(total_collisions)
		var i = 0
		for collision in total_collisions:
			if attack_hit_box.get_collider(i).is_in_group("bug"):
				print(i, "has taken damage")
				attack_hit_box.get_collider(i).take_damage(attack_damage)
			elif attack_hit_box.get_collider(i).is_in_group("player"):
				attack_hit_box.get_collider(i).take_damage(0)
				print("player was attacked")
			i += 1

# area contact with enemies for speed based damage and knockback
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("bug") and Vector2(velocity.x, velocity.z).length() > MIN_ROLLING_SPEED_FOR_ATTACK:
		var rollDamage = clampf(Vector2(velocity.x, velocity.z).length() * ROLLING_ATTACK_DAMAGE, 10, 50)
		body.take_damage(rollDamage)
		print(body.name, " took ", rollDamage, " rolling damage")

func cast_ability():
	animation_player.play("ability_use")
	ability_active = true
	var spawn = load("res://entities/abilities/SporeCloud.tscn").instantiate()
	add_sibling(spawn)
	print("ability has been cast")
	
	
func apply_knockback(direction: Vector3, force: float):
	velocity += direction.normalized() * force

func die():
	is_dead = true
	print("Player", player_id, "has died!")
	#animation_player.play("die")
	set_physics_process(false)
	SignalBus.player_died.emit()
	
	await get_tree().create_timer(respawn_delay).timeout
	respawn()
	
func respawn():
	is_dead = false
	#animation_player.play("Mushroomdude_Idle_v2/Armature_002|Armature_002Action_001")
	global_position = Vector3(5, 1, 5)
	print("player", player_id, "respawned!")
	current_health = max_health
	update()
	current_stamina = max_stamina
	update()
	set_physics_process(true)
	
	
