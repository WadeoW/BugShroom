extends ProgressBar

@onready var player = get_tree().get_first_node_in_group("player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()
	max_value = player.max_stamina

func update():
	value = player.current_stamina
