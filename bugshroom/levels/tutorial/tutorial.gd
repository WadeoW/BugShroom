extends Control




var cursor_speed = 500
@onready var cursor: Area2D = $CanvasLayer/Cursor
@onready var cursor_2: Area2D = $CanvasLayer/Cursor2




func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)



func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/Title Screen/title_screen.tscn")
