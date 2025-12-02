extends BugBase

@export var ant_speed: float = 5.0
@export var ant_health: float = 50.0
@export var ant_damage: float = 10.0
@export var ant_nutrient_value: float = 50


func _ready():
	# Initialize Ant stats based on exported variables
	speed = ant_speed
	health = ant_health
	damage = ant_damage
	bug_nutrient_value = ant_nutrient_value

	# Call parent _ready() so BugBase setup runs (like target assignment and bug_count)
	super._ready()
