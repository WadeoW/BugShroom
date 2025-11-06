extends BugBase

@export var ant_speed: float = 5.0
@export var ant_health: float = 50.0
@export var ant_damage: float = 10.0

func _ready():
	# Initialize Ant stats based on exported variables
	speed = ant_speed
	health = ant_health
	damage = ant_damage

	# Call parent _ready() so BugBase setup runs (like target assignment and bug_count)
	super._ready()
