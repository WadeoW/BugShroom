extends StaticBody3D

@export var pedestal_number = 1

@onready var hint_text: RichTextLabel = $SubViewport/HintText
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var snapping_point: Node3D = $SnappingPoint
@onready var celebration_particles: GPUParticles3D = $CelebrationParticles

var currently_holding_object = false
var held_object: RigidBody3D = null

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
		snap_object(body)
		


func _on_snapping_radius_body_exited(body: Node3D) -> void:
	if body == held_object:
		held_object = null
		currently_holding_object = false
		print("no longer holding: ", held_object)
