extends BugBase

@export var beetle_speed: float = 4.0
@export var beetle_health: float = 300.0
@export var beetle_damage: float = 40.0
@export var beetle_attack_speed: float = 2.5
@export var knockback_force: float = 20.0
@export var beetle_attack_range: float = 6
@export var beetle_nutrient_value: float = 100
@onready var animation_player: AnimationPlayer = $beetle_walkanimation/AnimationPlayer
const hit_delay = 0.4 #change with attack animation speed

func _ready() -> void:
	speed = beetle_speed
	health = beetle_health
	damage = beetle_damage
	attack_range = beetle_attack_range
	aggressive = true
	add_to_group("beetles")
	add_to_group("bug")
	super._ready()
	animation_player.play("beetle_walkanimation")
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: StringName):
	print("on animation finished triggered")
	if anim_name == "beetle_animations/beetle_attack2":
		animation_player.play("beetle_walkanimation")

# this initially checks for a player in the attack hitbox and then plays the attack animation and then waits hit_delay seconds
# to call hit_player which checks again if the player is in the hitbox (so they have a small chance to escape) before applying damage
func _try_attack() -> void:
	if not aggressive:
		return
	if not target or not can_attack:
		return
	var playerInRange := false
	if attack_hit_box.is_colliding():
		var total_collisions = attack_hit_box.get_collision_count()
		print("total beetle attack collisions: ", total_collisions)
		var i = 0
		for collision in range(total_collisions):
			var collidedObject = attack_hit_box.get_collider(i)
			print(collidedObject.name)
			if collidedObject != null && collidedObject.is_in_group("player") and not collidedObject.is_dead:
				playerInRange = true
			i += 1
		if playerInRange:
			animation_player.play("beetle_animations/beetle_attack2")
			can_attack = false
			await get_tree().create_timer(hit_delay).timeout
			hit_player()

func hit_player() -> void:
	if attack_hit_box.is_colliding():
		var total_collisions = attack_hit_box.get_collision_count()
		var i = 0
		for collision in range(total_collisions):
			var collidedObject = attack_hit_box.get_collider(i)
			if collidedObject.is_in_group("player") and not target.is_dead:
				if collidedObject.has_method("take_damage"):
					collidedObject.take_damage(damage)
					print("Beetle attacked player for ", damage, " damage!")
				if collidedObject.has_method("apply_knockback"):
					var direction := (target.global_position - global_position).normalized()
					direction.y = 0
					target.apply_knockback(Vector3(direction.x, 0.5, direction.z), knockback_force)
			i += 1
		await get_tree().create_timer(beetle_attack_speed).timeout
		can_attack = true
