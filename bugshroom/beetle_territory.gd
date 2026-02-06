extends Area3D
var creature_in_radius = false
var current_players_in_radius = []
var current_bugs_in_radius = []

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		current_players_in_radius.append(body)
	elif body.is_in_group("bug"):
		current_bugs_in_radius.append(body)
	creature_in_radius = true
