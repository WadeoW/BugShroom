extends ProgressBar

@onready var puffball = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	max_value = puffball.max_health
	update()

func update():
	value = puffball.current_health 
