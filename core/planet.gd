extends Node3D

@export var stone_block_scene: PackedScene

@onready var mesh_instance := $WorldMesh

func _ready():
	_generate_random_world(Vector3i(80, 40, 80))


func _generate_random_world(world_size: Vector3i):
	var cube_positions: Dictionary[Vector3i, int]
	var rng := FastNoiseLite.new()
	rng.seed = randi()

	for x in range(world_size.x):
		for y in range(world_size.y):
			for z in range(world_size.z):
			#	if rng.get_noise_3d(x, y, z) > 0:
			#		positions_of_cubes.append(Vector3(x, y, z))
				cube_positions[Vector3i(x, y, z)] = 1

	mesh_instance.create_surface_with_invisible_faces_hidden(cube_positions)
