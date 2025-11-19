extends BugBase
@export var beetle_speed: float = 2.0
@export var beetle_health: float = 80.0
@export var beetle_damage: float = 40.0

func _ready():
	speed = beetle_speed
	health = beetle_damage
	damage = beetle_damage
	aggressive = true
	
	super._ready()
