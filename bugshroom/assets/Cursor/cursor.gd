extends Area2D

@export var cursor_id: int
var cursor_speed = 500
var overlapping_buttons = []
var is_overlapping = false
@export var texture = Texture2D
@onready var sprite_2d: Sprite2D = $Sprite2D



func _input(event: InputEvent) -> void:
	#if cursor_id == 1:
	if event.is_action_pressed("click_%s" % [cursor_id]) and is_overlapping:
		#var i = overlapping_buttons[0]
		#print(i)
		#if i.get_parent() is Button:
			#var button = i.get_parent()
			#print(button)
			#button.pressed
		var mouse_click_event = InputEventMouseButton.new()
		mouse_click_event.button_index = MOUSE_BUTTON_LEFT
		mouse_click_event.pressed = true
		mouse_click_event.position = position
		Input.warp_mouse(position)
		Input.parse_input_event(mouse_click_event)
	if event.is_action_released("click_%s" % [cursor_id]):
		var mouse_click_event = InputEventMouseButton.new()
		mouse_click_event.button_index = MOUSE_BUTTON_LEFT
		mouse_click_event.pressed = false
		mouse_click_event.position = position
		Input.parse_input_event(mouse_click_event)

func _ready() -> void:
	sprite_2d.texture = texture

func _process(delta: float) -> void:
	
	#cursor 1
	if cursor_id == 1:
		var C1_direction = Vector2.ZERO
		
		C1_direction.x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		C1_direction.y = Input.get_joy_axis(0,JOY_AXIS_LEFT_Y)
		
		if C1_direction.length() > 1.0:
			C1_direction.normalized()
		
		var movement = C1_direction * cursor_speed * delta
		
		global_position += movement
	
	elif cursor_id == 2:
		var C1_direction = Vector2.ZERO
		C1_direction.x = Input.get_joy_axis(1, JOY_AXIS_LEFT_X)
		C1_direction.y = Input.get_joy_axis(1,JOY_AXIS_LEFT_Y)
		if C1_direction.length() > 1.0:
			C1_direction.normalized()
		var movement = C1_direction * cursor_speed * delta
		global_position += movement


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("button"):
		overlapping_buttons.append(area)
		#print("cursor overlapping with: ", area)
		is_overlapping = true
		


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("button"):
		overlapping_buttons.remove_at(0)
		#print("cursor no longer overlapping with: ", area)
		if overlapping_buttons == []:
			is_overlapping = false
			#print("no more overlaps")
