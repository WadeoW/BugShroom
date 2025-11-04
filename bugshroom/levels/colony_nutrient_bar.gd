extends ProgressBar


@export var main: Node3D

func _ready() -> void:
	max_value = main.max_colony_nutrients
	update()

func update():
	value = main.current_colony_nutrients
