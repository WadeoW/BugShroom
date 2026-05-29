extends Node3D

@export var surface_mesh_node: MeshInstance3D 
@export var item_to_scatter: PackedScene     
@export var count: int = 100 
@export var base_scale: float = 1.0

@export_group("Distribution Settings")
@export var min_distance: float = 0.5         # The minimum buffer distance between clovers
@export var max_retries_per_clover: int = 15  # How many times to try finding a valid spot before giving up

func _ready():
	if surface_mesh_node and item_to_scatter:
		populate()
	else:
		print("Warning: Please assign the Mesh and Clover Scene in the Inspector!")

func populate():
	var mesh = surface_mesh_node.mesh
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	
	var face_count = mdt.get_face_count()
	if face_count == 0:
		return
		
	var spawned_positions: Array[Vector3] = []
	var successful_spawns = 0
	var attempts = 0
	var absolute_max_attempts = count * max_retries_per_clover # Failsafe to prevent infinite loops
	
	# Keep trying to spawn clovers until we hit our target count or run out of valid space
	while successful_spawns < count and attempts < absolute_max_attempts:
		attempts += 1
		var face_idx = randi() % face_count
		
		# Barycentric Math
		var v1 = mdt.get_vertex(mdt.get_face_vertex(face_idx, 0))
		var v2 = mdt.get_vertex(mdt.get_face_vertex(face_idx, 1))
		var v3 = mdt.get_vertex(mdt.get_face_vertex(face_idx, 2))
		
		var a = randf()
		var b = randf()
		if a + b > 1.0:
			a = 1.0 - a
			b = 1.0 - b
		var c = 1.0 - a - b
		
		var local_pos = v1 * a + v2 * b + v3 * c
		var global_pos = surface_mesh_node.global_transform * local_pos
		
		# REJECTION SAMPLING: Check the distance to all previously spawned clovers
		var is_valid_spot = true
		for existing_pos in spawned_positions:
			if global_pos.distance_to(existing_pos) < min_distance:
				is_valid_spot = false
				break # Stop checking, we already know it's too close
				
		# If the spot passed the distance check, spawn the clover
		if is_valid_spot:
			spawned_positions.append(global_pos)
			spawn_clover_instance(global_pos)
			successful_spawns += 1
			
	# Print a console message if the plane runs out of room
	if successful_spawns < count:
		print("Grid saturated. Only fit ", successful_spawns, " clovers with a buffer of ", min_distance)

func spawn_clover_instance(spawn_pos: Vector3):
	var clover = item_to_scatter.instantiate()
	add_child(clover)
	
	clover.global_position = spawn_pos
	clover.rotation.y = randf_range(0, TAU)
	
	var random_scale = randf_range(0.8, 1.2) * base_scale
	clover.scale = Vector3(random_scale, random_scale, random_scale)
