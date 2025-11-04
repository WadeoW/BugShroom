extends StaticBody3D

@export var max_nutrients = 100
@export var current_nutrients = 100
var player_in_radius = false
var player_nutrient_drain_rate = 10

@export var nutrient_bar = ProgressBar

func _on_detection_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_radius = true


func _on_detection_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_radius = false
	

func _process(delta: float) -> void:
	if player_in_radius:
		current_nutrients -= player_nutrient_drain_rate * delta
		nutrient_bar.value = current_nutrients
	if nutrient_bar.value <= 0:
		despawn()
		

func despawn():
	queue_free()
