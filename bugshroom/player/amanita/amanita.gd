extends CharacterBody3D
class_name Amanita

signal player_death

# Movement variables
var speed
var WALK_SPEED = 4.0
var SPRINT_SPEED = 8.0
var inputVelocity: Vector2
var isSprinting: bool = false
const JUMP_VELOCITY = 8
const SENSITIVITY = 0.005
var gravity = 9.8
var knockback: Vector2
const MAX_KNOCKBACK_SPEED = 20
@export var player_id: int = 1
@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5

#animation control variables
var is_jumping = false
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state_playback = animation_tree.get("parameters/AnimationNodeStateMachine/playback")

#sound variables
@onready var jump_sound: AudioStreamPlayer = $PlayerModel/Audio/JumpSound
@onready var audio_listener_3d: AudioListener3D = $PlayerModel/Audio/AudioListener3D
@onready var walk_sound: AudioStreamPlayer = $PlayerModel/Audio/WalkSound
@onready var death_sound: AudioStreamPlayer = $PlayerModel/Audio/DeathSound


#respawn
@export var respawn_delay: float = 5.0

#health variables
@export var current_health = 100
@export var max_health = 100
@onready var health_bar: ProgressBar = $CanvasLayer/HealthBar
var is_dead = false

#stamina variables
@export var max_stamina = 100.0
@export var current_stamina = 100.0
var stamina_drain_rate = 5.0 #stamina drained per second during action
@onready var stamina_bar: ProgressBar = $CanvasLayer/StaminaBar

# grabbing variables
var isGrabbingItem: bool = false
@onready var grab_joint: Generic6DOFJoint3D = $"PlayerModel/Grab Joint"
@onready var dead_ant_grab_position: Node3D = $"PlayerModel/Grab Joint/Dead Ant Grab Position"
@onready var grab_hit_box: ShapeCast3D = $PlayerModel/GrabHitBox
@onready var player_model: Node3D = $PlayerModel # rotational basis
var grabbedItem: PhysicsBody3D

#attack variables
@export var attack_range: float = 3.0
@export var attack_damage: float = 20.0
var can_attack: bool = true
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var attack_hit_box: ShapeCast3D = $PlayerModel/AttackHitBox


#ability and class variables
var ability_active = false
var can_cast_abil = true
@onready var ability_type = load("res://entities/abilities/SporeRingAbility.tscn")
var mushroom_type = PlayerData.MushroomType.Amanita
@export var char_model: PackedScene
@onready var ability_cooldown: Timer = $AbilityCooldown

#Root Down Mechanic
var is_rooted = false
@export var root_stamina_regen = 15.0 #stamina regained per second while rooted

@onready var animation_player: AnimationPlayer = $PlayerModel/AnimationPlayer
@onready var camera_mount = $CameraMount
@onready var camera_yaw = $CameraMount/CameraYaw
@onready var camera_pitch = $CameraMount/CameraYaw/CameraPitch

#used for making smooth player turning
var last_direction = Vector3.FORWARD
@export var rotation_speed = 5

var current_animation: String = ""

func _ready() -> void:
	#animation_player.play("uncrouch")
	var current_animation = animation_player.current_animation
	#class selection and ability loading
	if player_id == 1:
		mushroom_type = PlayerData.p1_mushroom_type
	#debug
		print("p1 mushroom type :", mushroom_type)
	elif player_id == 2:
		mushroom_type = PlayerData.p2_mushroom_type
		print("player 2 mushroom type:", PlayerData.p2_mushroom_type)
	
	ability_type = load("res://entities/abilities/SporeRingAbility.tscn")
	print("ability type is spore ring")
	
	#set up health and stamina bars
	health_bar.max_value = max_health
	stamina_bar.max_value = max_stamina
	health_bar.value = health_bar.max_value
	stamina_bar.value = stamina_bar.max_value
	
	# you can't attack or grab yourself
	attack_hit_box.add_exception($".")
	grab_hit_box.add_exception($".")

func update()-> void:
	stamina_bar.value = current_stamina
	health_bar.value = current_health
	
func _unhandled_input(event):
	#root down input
	if event.is_action_pressed("root_%s" % [player_id]):
		toggle_root()
		
	if event.is_action_pressed("interact_%s" % [player_id]) and can_cast_abil == true and is_on_floor():
		cast_ability(ability_type)
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
	else:
		is_jumping = false
	# knockback decay
	knockback = knockback.move_toward(Vector2.ZERO, 20 * delta)
	if is_dead:
		knockback = Vector2.ZERO

# handle jump
	if Input.is_action_just_pressed("jump_%s" % [player_id]) and is_on_floor() and !is_rooted:
		jump_sound.play()
		velocity.y = JUMP_VELOCITY
		is_jumping = true

	if Input.is_action_just_pressed("attack_%s" % [player_id]) and attack_cooldown.is_stopped():
		attack()
		
	# grabbing
	if Input.is_action_just_pressed("grab_%s" % [player_id]):
		grab()
	if grabbedItem != null and grabbedItem.is_in_group("dead_bug"):
		grabbedItem.position = grabbedItem.position.move_toward(dead_ant_grab_position.global_position, 30 * delta)
		grabbedItem.rotation.y = lerp_angle(grabbedItem.rotation.y, player_model.rotation.y + (PI / 2), 30 * delta)
		grabbedItem.is_being_carried = true
		
	# handle sprint
	if Input.is_action_just_pressed("sprint_%s" % [player_id]) and current_stamina > 0:
		isSprinting = !isSprinting
	if isSprinting and current_stamina > 0:
		speed = SPRINT_SPEED
		if animation_player.current_animation == "walkanimation":
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
			#if animation_player.current_animation != "walkanimation" and animation_player.current_animation != "mushroomdude_allanimations2/attack" and animation_player.current_animation != "headshakeanimation/headshake" and animation_player.current_animation != "take_damage": 
				#animation_player.play("walkanimation")
			inputVelocity.x = direction.x * speed
			inputVelocity.y = direction.z * speed
			# sprinting
			if isSprinting and current_stamina > 0:
				current_stamina -= stamina_drain_rate * delta
				update()
				if current_stamina <= 0:
					isSprinting = false
		else:
			inputVelocity.x = lerp(inputVelocity.x, direction.x * speed, delta * 7.0)
			inputVelocity.y = lerp(inputVelocity.y, direction.z * speed, delta * 7.0)
			#if !animation_player.is_playing():
				#animation_player.play("Mushroomdude_Idle_v2/Armature_002|Armature_002Action_001")
		knockback = knockback.limit_length(MAX_KNOCKBACK_SPEED)
		velocity = Vector3(inputVelocity.x, velocity.y, inputVelocity.y) + Vector3(knockback.x, 0, knockback.y)
	else:
		velocity.x = 0
		velocity.z = 0

	if is_rooted:
		if current_stamina <= max_stamina:
			current_stamina += root_stamina_regen * delta
		update()
	
	$PlayerModel.rotation.y = lerp_angle($PlayerModel.rotation.y, atan2(-last_direction.x, -last_direction.z), delta * rotation_speed)

	move_and_slide()
	
	if velocity and not is_on_floor():
		if not walk_sound.playing:
			walk_sound.play()
		else:
			walk_sound.stop()

	
func take_damage(amount):
	#animation_player.play("take_damage")
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
		isSprinting = false
		print("Rooting Down")
		animation_state_playback.travel("crouch")
		#animation_player.play("crouch")
	else:
		animation_state_playback.travel("uncrouch")
		#animation_player.play("uncrouch")
		print("Uprooted")

func attack():
	#animation_player.play("mushroomdude_allanimations2/attack")
	animation_state_playback.travel("attack")
	can_attack = false
	attack_cooldown.start()
	var kb_direction: Vector3
	if attack_hit_box.is_colliding():
		var total_collisions = attack_hit_box.get_collision_count()
		print("total melee attack collisions: ", total_collisions)
		var i = 0
		for collision in range(total_collisions):
			var collidedObject = attack_hit_box.get_collider(i)
			print("melee attack hit: ", collidedObject.name)
			var horizontalKB: Vector2 = Vector2(collidedObject.position.x - position.x, collidedObject.position.z - position.z).normalized()
			kb_direction.x = horizontalKB.x
			kb_direction.z = horizontalKB.y
			kb_direction.y = 0.2
			if collidedObject.is_in_group("bug"):
				collidedObject.take_damage(attack_damage)
				if !collidedObject.is_in_group("beetles"):
					collidedObject.apply_knockback(kb_direction, 20)
			elif collidedObject.is_in_group("player"):
				collidedObject.apply_knockback(kb_direction, 3)
				print("player was attacked by other player")
			i += 1

	
func cast_ability(ability_type):
	animation_player.play("headshakeanimation/headshake")
	ability_active = true
	can_cast_abil = false
	var spawn = ability_type.instantiate()
	add_sibling(spawn)
	print("ability has been cast")

func grab():
	if not isGrabbingItem:
		if not grab_hit_box.is_colliding():
			print("nothing to grab")
			return
		var total_collisions = grab_hit_box.get_collision_count()
		var distanceToThing: float = 10000
		var closestBody: PhysicsBody3D
		var i = 0
		for collision in range(total_collisions):
			var thing = grab_hit_box.get_collider(i)
			var body := thing as Node
			while body and not (body is PhysicsBody3D):
				body = body.get_parent()
			if body is RigidBody3D:
				if (thing.global_position - global_position).length() < distanceToThing:
					distanceToThing = (thing.global_position - global_position).length()
					closestBody = body
			if body.is_in_group("dead_bug") and body is CharacterBody3D and not body.is_being_carried:
				closestBody = body
			i += 1
		if closestBody != null:
			grabbedItem = closestBody
			# body is part of environment
			if closestBody is RigidBody3D:
				grab_joint.node_b = closestBody.get_path()
			add_collision_exception_with(closestBody)
			print("grabbed ", grab_joint.node_b)
			isGrabbingItem = true
		else:
			print("no rigid or character bodies to grab")
	else:
		print("released ", grab_joint.node_b)
		remove_collision_exception_with(grabbedItem)
		if grabbedItem.is_in_group("dead_bug"):
			grabbedItem.is_being_carried = false
		grabbedItem = null
		grab_joint.node_b = NodePath()
		isGrabbingItem = false

func apply_knockback(direction: Vector3, force: float):
	knockback += Vector2(direction.x, direction.z).normalized() * force
	velocity.y += direction.normalized().y * force
	
func die():
	death_sound.play()
	is_dead = true
	print("Player", player_id, "has died!")
	animation_state_playback.travel("die")
	set_physics_process(false)
	SignalBus.player_died.emit()
	await get_tree().create_timer(respawn_delay).timeout
	respawn()
	
func respawn():
	is_dead = false
	knockback = Vector2.ZERO; velocity = Vector3.ZERO; inputVelocity = Vector2.ZERO
	global_position = Vector3(5, 1, 5)
	animation_state_playback.travel("run")
	print("player", player_id, "respawned!")
	current_health = max_health
	current_stamina = max_stamina
	update()
	set_physics_process(true)

	


func _on_ability_cooldown_timeout() -> void:
	can_cast_abil = true
