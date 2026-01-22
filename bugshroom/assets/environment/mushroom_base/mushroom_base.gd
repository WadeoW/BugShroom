extends Node3D

var player_in_base = true
var overlapping_bodies = []
@export var healing_amount:float = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and body not in overlapping_bodies:
		overlapping_bodies.append(body)
		player_in_base = true
	print("body entered: ", body.name)



func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and body in overlapping_bodies:
		overlapping_bodies.erase(body)
	if overlapping_bodies == []:
		player_in_base = false
	print("body exited: ", body.name)

#heal player when in base
func _on_heal_timer_timeout() -> void:
	if player_in_base:
		for player in overlapping_bodies:
			if player.has_method("heal"):
				player.heal(healing_amount)
