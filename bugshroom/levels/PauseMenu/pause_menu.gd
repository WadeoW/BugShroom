extends Control

var cursor_speed = 500
@onready var cursor_1: Area2D = $Cursor1
@onready var cursor_2: Area2D = $Cursor2

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("options_1") and get_tree().paused == false:
		get_tree().paused = true
	if Input.is_action_just_pressed("options_1") and get_tree().paused == true:
		get_tree().paused = false



func _ready() -> void: 
	pass
	
func pause() -> void:
	get_tree().paused = true

func resume() -> void:
	get_tree().paused = false


func _on_resume_pressed() -> void:
	resume()
	
func _on_change_character_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/Class Selection/class_selection.tscn")


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_quit_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/Title Screen/title_screen.tscn")
