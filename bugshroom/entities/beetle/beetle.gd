extends BugBase

@export var beetle_speed: float = 2.0
@export var beetle_health: float = 80.0
@export var beetle_damage: float = 40.0
@export var knockback_force: float = 12.0

func _ready() -> void:
	speed = beetle_speed
	health = beetle_health
	damage = beetle_damage
	aggressive = true
	add_to_group("beetles")
	add_to_group("bug")
	super._ready()

func _try_attack() -> void:
	if not target or not can_attack:
		return
	
	var distance := global_position.distance_to(target.global_position)
	if distance <= attack_range:
		can_attack = false
		
		var direction := (target.global_position - global_position).normalized()
		direction.y = 0
		
		if target.has_method("take_damage"):
			target.take_damage(damage)
			
		if target.has_method("apply_knockback"):
			target.apply_knockback(direction, knockback_force)

		print("Beetle smashed player for ", damage, " damage!")
		
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true
