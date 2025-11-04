extends Node3D


@export var player1 = CharacterBody3D
@export var player2 = CharacterBody3D
@onready var mushroom_base = $MushroomBase
@onready var nutrient_drain_timer: Timer = $NutrientDrainTimer
@onready var dead_bug_task_manager: Node3D = $DeadBugTaskManager
@onready var nutrient_gain_timer: Timer = $NutrientGainTimer


@export var colony_nutrient_bar = ProgressBar
@export var current_colony_nutrients: int = 1000
@export var max_colony_nutrients: int = 1000
var colony_nutrient_drain_rate = 5
var colony_nutrient_gain_rate = 15

@onready var players = {"player_1": player1, "player_2": player2}

func _ready() -> void:
	#mushroom_base.connect("")
	pass


func _process(delta: float) -> void:
	if dead_bug_task_manager.player_harvesting and nutrient_gain_timer.is_stopped():
		player_harvest()




func game_over():
	pass


func _on_nutrient_drain_timer_timeout() -> void:
	current_colony_nutrients -= colony_nutrient_drain_rate
	colony_nutrient_bar.update()
	if current_colony_nutrients <= 0:
		game_over()

func player_harvest():
	nutrient_gain_timer.start()


func _on_nutrient_gain_timer_timeout() -> void:
	current_colony_nutrients += colony_nutrient_gain_rate
