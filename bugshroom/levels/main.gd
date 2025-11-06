extends Node3D


@export var player1 = CharacterBody3D
@export var player2 = CharacterBody3D
@onready var mushroom_base = $MushroomBase
@onready var nutrient_drain_timer: Timer = $NutrientDrainTimer
@onready var nutrient_gain_timer: Timer = $NutrientGainTimer


@export var colony_nutrient_bar = ProgressBar
@export var current_colony_nutrients: int = 1000
@export var max_colony_nutrients: int = 1000
var colony_nutrient_drain_rate = 5
var colony_nutrient_gain_rate = 15

@onready var players = {"player_1": player1, "player_2": player2}

func _ready() -> void:
	SignalBus.start_player_harvesting_nutrients.connect(Callable(self, "_on_start_player_harvesting_nutrients"))
	SignalBus.stop_player_harvesting_nutrients.connect(Callable(self, "_on_stop_player_harvesting_nutrients"))
	SignalBus.game_over.connect(Callable(self, "_on_game_over"))


func _on_game_over():
	get_tree().reload_current_scene()
	get_tree().change_scene_to_file("res://levels/game over/game_over.tscn")


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
