extends NavigationRegion3D

@onready var player_detection_radius: Area3D = $PlayerDetectionRadius
var player_in_ant_hill = false
var current_players_in_ant_hill = []

func _on_player_detection_radius_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_ant_hill = true
		current_players_in_ant_hill.append(body)
		SignalBus.player_entered_ant_hill.emit()


func _on_player_detection_radius_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		if body in current_players_in_ant_hill:
			current_players_in_ant_hill.erase(body)
			
	if current_players_in_ant_hill == []:
		SignalBus.all_players_exited_ant_hill.emit()
