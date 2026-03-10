extends Control


var cursor_speed = 500
@onready var cursor: Area2D = $CanvasLayer2/Cursor
@onready var cursor_2: Area2D = $CanvasLayer/CanvasLayer2/Cursor2

@onready var credits: TextureRect = $CanvasLayer2/Credits




func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/Title Screen/title_screen.tscn")


func _on_credits_button_pressed() -> void:
	credits.visible = !credits.visible
