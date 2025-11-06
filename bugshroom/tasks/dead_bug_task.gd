extends StaticBody3D

@export var max_nutrients = 100
@export var current_nutrients = 100
var player_in_radius = false
var player_nutrient_drain_rate = 10
var bodies_in_radius = []
@export var nutrient_bar = ProgressBar

func _ready() -> void:
	SignalBus.dead_bug_task_finished.connect(Callable(self, "_on_dead_bug_task_finished"))

func _on_detection_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		bodies_in_radius.append(body)
		SignalBus.start_player_harvesting_nutrients.emit()
		player_in_radius = true


func _on_detection_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		bodies_in_radius.erase(body)
	if bodies_in_radius == []:
		player_in_radius = false
		SignalBus.stop_player_harvesting_nutrients.emit()


func _process(delta: float) -> void:
	if player_in_radius:
		current_nutrients -= player_nutrient_drain_rate * delta
		nutrient_bar.value = current_nutrients
	if nutrient_bar.value <= 0:
		despawn()
		
		

func despawn():
	player_in_radius = false
	SignalBus.dead_bug_task_finished.emit()
	queue_free()
