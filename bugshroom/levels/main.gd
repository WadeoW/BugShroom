extends Node3D


@export var player1 = CharacterBody3D
@export var player2 = CharacterBody3D
@onready var mushroom_base = $MushroomBase


#Colony nutrient variables
@export var colony_nutrient_bar = ProgressBar
@export var current_colony_nutrients: int = 1000
@export var max_colony_nutrients: int = 1000
@export var colony_nutrient_drain_rate = 0
var colony_nutrient_gain_rate = 25
@onready var nutrient_drain_timer: Timer = $NutrientDrainTimer
@onready var nutrient_gain_timer: Timer = $NutrientGainTimer


#pause menue variables
@onready var pause_menu: Control = $PauseMenuCanvasLayer/PauseMenu
@onready var pause_menu_canvas_layer: CanvasLayer = $PauseMenuCanvasLayer

#Sound Variables
@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var beetle_track: AudioStreamPlayer = $BeetleTrack

#BossBeetleSpawning variables
@onready var boss_beetle_scene = preload("res://entities/beetle/BossBeetle.tscn")
@onready var boss_beetle_spawnpoint: Node3D = $BossBeetleSpawnpoint
@onready var boss_beetle_warning: RichTextLabel = $CanvasLayer/BossBeetleWarning
@onready var boss_beetle_animation_player: AnimationPlayer = $CanvasLayer/BossBeetleWarning/BossBeetleAnimationPlayer
@onready var boss_beetle_alert_sound: AudioStreamPlayer = $CanvasLayer/BossBeetleWarning/BossBeetleAnimationPlayer/BossBeetleAlertSound

#player spawners
@onready var player_1_spawner: Node3D = $GridContainer/SubViewportContainer/SubViewport/Player1Spawner
@onready var player_2_spawner: Node3D = $GridContainer/SubViewportContainer2/SubViewport/Player2Spawner

@onready var players = {"player_1": player1, "player_2": player2}

#pedestal collection variables
@onready var mushroom_pedestal: StaticBody3D = $MushroomPedestal
@onready var mushroom_pedestal_2: StaticBody3D = $MushroomPedestal2
@onready var mushroom_pedestal_3: StaticBody3D = $MushroomPedestal3
@onready var mushroom_pedestal_4: StaticBody3D = $MushroomPedestal4



func _ready() -> void:
	boss_beetle_warning.self_modulate = Color(0, 0, 0, 0)
	SignalBus.start_player_harvesting_nutrients.connect(Callable(self, "_on_start_player_harvesting_nutrients"))
	SignalBus.stop_player_harvesting_nutrients.connect(Callable(self, "_on_stop_player_harvesting_nutrients"))
	SignalBus.game_over.connect(Callable(self, "_on_game_over"))
	SignalBus.player_died.connect(Callable(self, "_on_player_death"))
	SignalBus.player_entered_beetle_territory.connect(Callable(self, "_on_player_entered_beetle_territory"))
	SignalBus.player_exited_beetle_territory.connect(Callable(self, "_on_player_exited_beetle_territory"))

func _process(_delta: float) -> void:
	if mushroom_pedestal.pinecone_collected and mushroom_pedestal_2.rock_collected and mushroom_pedestal_3.ant_queen_head_collected and mushroom_pedestal_4.boss_beetle_head_collected:
			get_tree().change_scene_to_file("res://levels/WinScreen/win_screen.tscn")
	
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

func _on_player_death(player):
	current_colony_nutrients -= 100
	if player == 1:
		print("player 1 has died")
		player_1_spawner.spawn_player()
	if player == 2:
		print("player 2 has died")
		player_2_spawner.spawn_player()
	

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


func _on_boss_beetle_spawner_timeout() -> void:
	var boss_beetle = boss_beetle_scene.instantiate()
	add_child(boss_beetle)
	boss_beetle.global_position = boss_beetle_spawnpoint.global_position
	boss_beetle_alert_sound.play()
	boss_beetle_animation_player.play("flashing")
