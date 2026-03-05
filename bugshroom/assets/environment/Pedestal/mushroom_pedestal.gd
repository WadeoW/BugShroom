extends StaticBody3D

@export var pedestal_number = 1

@onready var hint_text: RichTextLabel = $SubViewport/HintText
@onready var sprite_3d: Sprite3D = $Sprite3D

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
