extends Control

var cursor_speed = 500
@onready var cursor: Area2D = $CanvasLayer2/Cursor
@onready var cursor_2: Area2D = $CanvasLayer2/Cursor2
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer



func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/tutorial/tutorial.tscn")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	audio_stream_player.play()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/Class Selection/class_selection.tscn")
