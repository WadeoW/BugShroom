extends ProgressBar

@export var player : CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()
	max_value = player.max_stamina

func update():
	value = player.current_stamina
