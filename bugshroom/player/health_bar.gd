extends ProgressBar

@export var player: CharacterBody3D

func _ready() -> void:
	max_value = player.max_health
	update()

func update():
	value = player.current_health 
