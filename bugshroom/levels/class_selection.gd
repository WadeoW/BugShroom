extends Control

var cursor_speed = 500
@onready var cursor: Sprite2D = $CanvasLayer2/cursor

#func _on_start_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://Main.tscn")


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var mouse_click_event = InputEventMouseButton.new()
		mouse_click_event.button_index = MOUSE_BUTTON_LEFT
		mouse_click_event.pressed = true
		mouse_click_event.position = cursor.global_position
		Input.parse_input_event(mouse_click_event)
		print("button is being pressed")
	if event.is_action_released("click"):
		var mouse_click_event = InputEventMouseButton.new()
		mouse_click_event.button_index = MOUSE_BUTTON_LEFT
		mouse_click_event.pressed = false
		mouse_click_event.position = cursor.global_position
		Input.parse_input_event(mouse_click_event)
		print("button is being released")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var C1_direction = Vector2.ZERO
	
	C1_direction.x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	C1_direction.y = Input.get_joy_axis(0,JOY_AXIS_LEFT_Y)
	
	if C1_direction.length() > 1.0:
		C1_direction.normalized()
	
	var movement = C1_direction * cursor_speed * delta
	
	cursor.global_position += movement
	
	Input.warp_mouse(cursor.global_position)
