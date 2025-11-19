extends BugBase
@export var aphid_speed: float = 3.0
@export var aphid_health: float = 10.0

func _ready():
	speed = aphid_speed
	health = aphid_health
	aggressive = false
	
	super._ready()
