extends Control



func _on_try_again_pressed() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")


func _on_return_to_title_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/Title Screen/title_screen.tscn")
