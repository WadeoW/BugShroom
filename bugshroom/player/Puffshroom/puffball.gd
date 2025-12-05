extends Player

@export var puff_walk_speed = 6
@export var puff_sprint_speed = 10



func _ready() -> void:
	super._ready()
	WALK_SPEED = puff_walk_speed
	SPRINT_SPEED = puff_sprint_speed
	animation_player = $CharacterModel/AnimationPlayer
