extends Node3D


@export var player1 = CharacterBody3D
@export var player2 = CharacterBody3D
@onready var mushroom_base = $MushroomBase
@onready var nutrient_drain_timer: Timer = $NutrientDrainTimer
@onready var nutrient_gain_timer: Timer = $NutrientGainTimer

@export var colony_nutrient_bar = ProgressBar
@export var current_colony_nutrients: int = 1000
@export var max_colony_nutrients: int = 1000
@export var colony_nutrient_drain_rate = 0
var colony_nutrient_gain_rate = 25

@onready var pause_menu: Control = $PauseMenuCanvasLayer/PauseMenu
@onready var pause_menu_canvas_layer: CanvasLayer = $PauseMenuCanvasLayer


@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var beetle_track: AudioStreamPlayer = $BeetleTrack


@onready var players = {"player_1": player1, "player_2": player2}

func _ready() -> void:
	SignalBus.start_player_harvesting_nutrients.connect(Callable(self, "_on_start_player_harvesting_nutrients"))
	SignalBus.stop_player_harvesting_nutrients.connect(Callable(self, "_on_stop_player_harvesting_nutrients"))
	SignalBus.game_over.connect(Callable(self, "_on_game_over"))
	SignalBus.player_died.connect(Callable(self, "_on_player_death"))
	SignalBus.player_entered_beetle_territory.connect(Callable(self, "_on_player_entered_beetle_territory"))
	SignalBus.player_exited_beetle_territory.connect(Callable(self, "_on_player_exited_beetle_territory"))

func _process(_delta: float) -> void:
	#allows you to hit the escape key to get mouse cursor back
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("options_1") and get_tree().paused == false:
		pause_menu_canvas_layer.visible = true
	if Input.is_action_just_pressed("options_1") and get_tree().paused == true:
		pause_menu_canvas_layer.visible = false
		

func _on_game_over():
	#get_tree().reload_current_scene()
	get_tree().change_scene_to_file("res://levels/gameover/game_over.tscn")

func _on_player_death():
	current_colony_nutrients -= 100

func _on_nutrient_drain_timer_timeout() -> void:
	current_colony_nutrients -= colony_nutrient_drain_rate
	colony_nutrient_bar.update()
	if current_colony_nutrients <= 0:
		SignalBus.game_over.emit()

func player_harvest():
	nutrient_gain_timer.start()


func _on_nutrient_gain_timer_timeout() -> void:
	current_colony_nutrients += colony_nutrient_gain_rate

func _on_start_player_harvesting_nutrients():
	nutrient_gain_timer.start()

func _on_stop_player_harvesting_nutrients():
	nutrient_gain_timer.stop()

func _on_player_entered_beetle_territory():
	if background_music.playing:
		background_music.stop()
	if !beetle_track.playing:
		beetle_track.play()

func _on_player_exited_beetle_territory():
	if beetle_track.playing:
		beetle_track.stop()
	if !background_music.playing:
		background_music.play()
