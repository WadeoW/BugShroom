extends Node3D

@onready var yaw_node = $CameraYaw
@onready var pitch_node = $CameraYaw/CameraPitch
@onready var camera = %Camera3D
@onready var parent_node = get_parent()
@onready var player_id = parent_node.player_id


var yaw : float = 0
var pitch : float = 0

var yaw_sensitivity : float = 0.07
var pitch_sensitivity : float = 0.07

var yaw_acceleration : float = 15
var pitch_acceleration : float = 15

var pitch_max : float = 75
var pitch_min : float = -55

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	print("value from parent:" , player_id)

func _input(event):
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += event.relative.y * pitch_sensitivity
		
func _physics_process(delta):
	
	var input_dir = Input.get_vector("look_left_%s" % [player_id], "look_right_%s" % [player_id], "look_up_%s" % [player_id], "look_down_%s" % [player_id])
	
	yaw_node.rotate_y(-input_dir.x * yaw_sensitivity) 
	pitch_node.rotate_x(-input_dir.y * pitch_sensitivity)
	
	pitch_node.rotation.x = clamp(pitch_node.rotation.x, deg_to_rad(pitch_min), deg_to_rad(pitch_max))

	
