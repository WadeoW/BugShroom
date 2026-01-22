extends CharacterBody3D
class_name Inkcap

signal player_death

var speed
var WALK_SPEED = 4.0
var SPRINT_SPEED = 8.0
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
var is_dead = false
@onready var health_bar: ProgressBar = $CanvasLayer/HealthBar


#stamina variables
@export var max_stamina = 100.0
@export var current_stamina = 100.0
var stamina_drain_rate = 5.0 #stamina drained per second during action
@onready var stamina_bar: ProgressBar = $CanvasLayer/StaminaBar

#attack variables
@export var attack_range: float = 3.0
@export var attack_damage: float = 20.0
var can_attack: bool = true
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var attack_hit_box: ShapeCast3D = $AttackHitBox


#ability and class variables
var can_cast_abil = true
var ability_active = false
var goop_ball_launch_speed: float = 10
@onready var ability_type = null
var mushroom_type = PlayerData.MushroomType.Inkcap
@export var char_model: PackedScene
@onready var ability_cooldown: Timer = $AbilityCooldown

#Root Down Mechanic
var is_rooted = false
@export var root_stamina_regen = 15.0 #stamina regained per second while rooted

@onready var animation_player: AnimationPlayer = $inkmushroom/AnimationPlayer
@onready var camera_mount = $CameraMount
@onready var camera_yaw = $CameraMount/CameraYaw
@onready var camera_pitch = $CameraMount/CameraYaw/CameraPitch

#used for making smooth player turning
var last_direction = Vector3.FORWARD
@export var rotation_speed = 5

var current_animation: String = ""

func _ready() -> void:
	animation_player.play("INK-Shroom_Run_Jump_Idel/Idel")
	var current_animation = animation_player.current_animation
	#set up health and stamina bars
	health_bar.max_value = max_health
	stamina_bar.max_value = max_stamina
	health_bar.value = health_bar.max_value
	stamina_bar.value = stamina_bar.max_value
	
	
	#class selection and ability loading
	if player_id == 1:
		mushroom_type = PlayerData.p1_mushroom_type
	#debug
		print("p1 mushroom type :", mushroom_type)
	elif player_id == 2:
		mushroom_type = PlayerData.p2_mushroom_type
		print("player 2 mushroom type:", PlayerData.p2_mushroom_type)
	
	if mushroom_type == 0:
		ability_type = load("res://entities/abilities/SporeRingAbility.tscn")
		print("ability type is spore ring")
	elif mushroom_type == 1:
		ability_type = load("res://entities/abilities/GoopBall.tscn")
	elif mushroom_type == PlayerData.MushroomType.Puffball:
		ability_type = load("res://entities/abilities/SporeCloud.tscn")
		print("ability type is spore cloud")

func update() -> void:
	health_bar.value = current_health
	stamina_bar.value = current_stamina 
	
func _unhandled_input(event):
	#root down input
	if event.is_action_pressed("root_%s" % [player_id]):
		toggle_root()
		
#ability casting
	if event.is_action_pressed("interact_%s" % [player_id]) and can_cast_abil == true:
		cast_ability(ability_type)	
		#debug
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
		animation_player.play("INK-Shroom_Run_Jump_Idel/Jump")

#handle attack
	if Input.is_action_just_pressed("attack_%s" % [player_id]) and attack_cooldown.is_stopped():
		attack()
		

	# handle sprint
	if Input.is_action_pressed("sprint_%s" % [player_id]) and current_stamina > 0:
		current_stamina -= stamina_drain_rate * delta
		update()
		speed = SPRINT_SPEED
		if animation_player.current_animation == "INK-Shroom_Run_Jump_Idel/Running":
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
			if animation_player.current_animation != "INK-Shroom_Run_Jump_Idel/Running" and animation_player.current_animation != "take_damage" and animation_player.current_animation != "INK-Shroom_Run_Jump_Idel/Jump": 
				animation_player.play("INK-Shroom_Run_Jump_Idel/Running")
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
			if !animation_player.is_playing():
				animation_player.play("INK-Shroom_Run_Jump_Idel/Idel")
	else:
		velocity.x = 0
		velocity.z = 0 
	
	if is_rooted:
		if current_stamina <= max_stamina:
			current_stamina += root_stamina_regen * delta
		update()
	
	$inkmushroom.rotation.y = lerp_angle($inkmushroom.rotation.y, atan2(-last_direction.x, -last_direction.z), delta * rotation_speed)

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

	
func cast_ability(ability_type):
	#animation_player.play("headshakeanimation/headshake")
	ability_active = true
	can_cast_abil = false
	var spawn := load("res://entities/abilities/GoopBall.tscn").instantiate() as RigidBody3D
	add_sibling(spawn)
	spawn.position = position + Vector3.UP * 2
	var launchDirection = -camera_pitch.global_transform.basis.z
	spawn.linear_velocity = launchDirection.normalized() * goop_ball_launch_speed + Vector3.UP * 5
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
	animation_player.play("INK-Shroom_Run_Jump_Idel/Idel")
	global_position = Vector3(5, 1, 5)
	print("player", player_id, "respawned!")
	current_health = max_health
	current_stamina = max_stamina
	update()
	set_physics_process(true)
	
	


func _on_ability_cooldown_timeout() -> void:
	can_cast_abil = true
