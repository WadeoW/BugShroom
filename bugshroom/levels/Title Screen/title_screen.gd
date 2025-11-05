extends Control


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")


func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/tutorial/tutorial.tscn")
