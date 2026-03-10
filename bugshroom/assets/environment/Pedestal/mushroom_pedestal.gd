extends StaticBody3D

@export var pedestal_number = 1

@onready var hint_text: RichTextLabel = $SubViewport/HintText
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var snapping_point: Node3D = $SnappingPoint
@onready var celebration_particles: GPUParticles3D = $CelebrationParticles

var currently_holding_object = false
var held_object: RigidBody3D = null
var pinecone_collected = false
var rock_collected = false
var ant_queen_head_collected = false
var boss_beetle_head_collected = false

func _ready() -> void:
	if pedestal_number == 1: #pinecone pedestal
		hint_text.add_text("Rumor has it, 
this relic lies high up in the trees")
	if pedestal_number == 2: #Rock pedestal
		hint_text.add_text("A very special rock goes here")
	if pedestal_number == 3: #ant queen head pedestal
		hint_text.add_text("The head of the swarm belongs on this toadstool")
	if pedestal_number == 4: #beetle head pedestal
		hint_text.add_text("Find this figure where the ground shakes and a beast roars")

func _process(delta: float) -> void:
	pass

func snap_object(collectible):
	collectible.global_position = snapping_point.global_position
	collectible.rotation = Vector3.ZERO
	collectible.freeze = true
	print("collectible snapped to pedestal")
	if held_object == null:
		held_object = collectible
	currently_holding_object = true
	celebration_particles.emitting = true
	hint_text.text = ""
	


func _on_snapping_radius_body_entered(body: Node3D) -> void:
	if body.is_in_group("Collectible") and body is RigidBody3D and currently_holding_object == false:
		if pedestal_number == 1 and body.is_in_group("Pinecone"):
			snap_object(body)
			pinecone_collected = true
			print("pinecone collected! Pinecone collected = ", pinecone_collected)
		if pedestal_number == 2 and body.is_in_group("Rock_Collectible"):
			snap_object(body)
			rock_collected = true
			print("rock collected! rock collected = ", rock_collected)

		if pedestal_number ==3 and body.is_in_group("Ant_Queen_Head"):
			snap_object(body)
			ant_queen_head_collected = true
			print("ant queen head collected! ant queen collected = ", ant_queen_head_collected)
		if pedestal_number == 4 and body.is_in_group("Boss_Beetle_Head"):
			snap_object(body)
			boss_beetle_head_collected = true
			print("beetle head collected! beetle head collected = ", boss_beetle_head_collected)


func _on_snapping_radius_body_exited(body: Node3D) -> void:
	if body == held_object:
		print("no longer holding: ", held_object)
		held_object = null
		currently_holding_object = false
