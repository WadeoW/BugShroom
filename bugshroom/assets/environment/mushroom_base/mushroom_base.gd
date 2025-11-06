extends Node3D

var player_in_base = true
var overlapping_bodies = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


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
