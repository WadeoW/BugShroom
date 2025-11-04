extends Node3D

@onready var current_tasks = get_children()
var player_harvesting = false
@onready var last_number_of_tasks #= get_children()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var last_number_of_tasks = current_tasks

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	check_for_players(current_tasks)

func check_for_players(current_tasks):
	current_tasks = get_children()
	if current_tasks != last_number_of_tasks:
		last_number_of_tasks = current_tasks
		player_harvesting = false
	for task in current_tasks:
		if task.player_in_radius:
			player_harvesting = true
		
