extends Area3D
var creature_in_radius = false
var current_players_in_radius = []
var current_bugs_in_radius = []
var beetle : CharacterBody3D = null

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		current_players_in_radius.append(body)
		print("new player added to current_players_in_radius")
	if body.is_in_group("ant") or body.is_in_group("aphid"):
		current_bugs_in_radius.append(body)
		print("new bug added to current_bugs_in_radius: " + current_bugs_in_radius)
	creature_in_radius = true
	if body.is_in_group("beetle") and beetle == null:
		beetle = body
		print("new beetle set: ")
		print(beetle)
