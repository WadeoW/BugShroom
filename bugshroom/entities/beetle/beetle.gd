extends BugBase

@export var beetle_speed: float = 4.0
@export var beetle_health: float = 300.0
@export var beetle_damage: float = 40.0
@export var knockback_force: float = 20.0
@export var beetle_attack_range: float = 6
@export var beetle_nutrient_value: float = 100
@onready var animation_player: AnimationPlayer = $beetle_walkanimation/AnimationPlayer
const hit_delay = 0.4 #change with attack animation speed

#health bar variable
@onready var health_bar_3d: ProgressBar = $SubViewport/HealthBar3D

#sound variables
@onready var death_sound: AudioStreamPlayer = $Audio/DeathSound
@onready var attack_sound: AudioStreamPlayer = $Audio/AttackSound

func _ready() -> void:
	speed = beetle_speed
	health = beetle_health
	damage = beetle_damage
	attack_range = beetle_attack_range
	aggressive = true
	add_to_group("beetles")
	add_to_group("bug")
	super._ready()
	health_bar_3d.max_value = beetle_health
	health_bar_3d.value = health
	
	
	animation_player.play("beetle_walkanimation")

func _try_attack() -> void:
	if not target or not can_attack:
		return
	
	var distance := global_position.distance_to(target.global_position)
	if distance <= attack_range:
		attack_sound.play()
		can_attack = false
		animation_player.play("beetle_animations/beetle_attack2")
		var direction := (target.global_position - global_position).normalized()
		direction.y = 0
		
		await get_tree().create_timer(hit_delay).timeout
		
		if target.has_method("take_damage"):
			target.take_damage(damage)
			
		if target.has_method("apply_knockback"):
			target.apply_knockback(Vector3(direction.x, 0.5, direction.z), knockback_force)

		print("Beetle smashed player for ", damage, " damage!")
		
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true



func take_damage(amount: float) -> void:
	super.take_damage(amount)
	_update()
	

func die() -> void:
	death_sound.play()
	super.die()

func _update() -> void:
	health_bar_3d.value = health
