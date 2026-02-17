extends Control

var cursor_speed = 500
@onready var cursor: Area2D = $CanvasLayer2/Cursor
@onready var cursor_2: Area2D = $CanvasLayer2/Cursor2

@onready var amanita: Button = $CanvasLayer2/Amanita
@onready var puffball: Button = $CanvasLayer2/Puffball
@onready var inkcap: Button = $CanvasLayer2/Inkcap

@onready var player_1_icon: TextureRect = $CanvasLayer/player1Icon
@onready var player_2_icon: TextureRect = $CanvasLayer/player2Icon



#func _on_start_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://Main.tscn")


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	#cursor.global_position = Vector2(100, 100)
	#cursor_2.global_position = Vector2(200, 100)
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	




func _on_amanita_pressed() -> void:
	print("amanita button being pressed")
	if cursor.overlaps_area($CanvasLayer2/Amanita/Area2D):
		PlayerData.p1_mushroom_type = PlayerData.MushroomType.Amanita
		player_1_icon.texture = preload("res://assets/UI/Amanita Brown Cap Character Select.png")
		#print("player 1 selected amanita")
		#print(PlayerData.p1_mushroom_type)
	if cursor_2.overlaps_area($CanvasLayer2/Amanita/Area2D):
		PlayerData.p2_mushroom_type = PlayerData.MushroomType.Amanita
		player_2_icon.texture = preload("res://assets/UI/Amanita Brown Cap Character Select.png")
		#print("player 2 selected amanita")
		#print(PlayerData.p2_mushroom_type)

func _on_puffball_pressed() -> void:
	print("puffball button being pressed")
	if cursor.overlaps_area($CanvasLayer2/Puffball/Area2D):
		PlayerData.p1_mushroom_type = PlayerData.MushroomType.Puffball
		player_1_icon.texture = preload("res://assets/UI/Puffball Character Select.png")
		#print("player 1 selected puffball")
		#print(PlayerData.p1_mushroom_type)
		
	if cursor_2.overlaps_area($CanvasLayer2/Puffball/Area2D):
		PlayerData.p2_mushroom_type = PlayerData.MushroomType.Puffball
		player_2_icon.texture = preload("res://assets/UI/Puffball Character Select.png")
		#print("player 2 selected puffball")
		#print(PlayerData.p2_mushroom_type)

func _on_inkcap_pressed() -> void:
	print("inkcap button being pressed")
	if cursor.overlaps_area($CanvasLayer2/Inkcap/Area2D):
		PlayerData.p1_mushroom_type = PlayerData.MushroomType.Inkcap
		player_1_icon.texture = preload("res://assets/UI/Inkcap Character Select.png")
		#print("player 1 selected inkcap")
		#print(PlayerData.p1_mushroom_type)
		
	if cursor_2.overlaps_area($CanvasLayer2/Inkcap/Area2D):
		PlayerData.p2_mushroom_type = PlayerData.MushroomType.Inkcap
		player_2_icon.texture = preload("res://assets/UI/Inkcap Character Select.png")

		
		#print("player 2 selected inkcap")
		#print(PlayerData.p2_mushroom_type)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/Title Screen/title_screen.tscn")


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")
