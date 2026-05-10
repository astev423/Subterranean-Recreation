extends Node3D

@export var stone_block_scene: PackedScene
@export var chunk_scene: PackedScene

const CHUNK_SIZE := Vector3i(32, 16, 32)

func _ready():
	_generate_chunks(3, 3)

func _generate_chunks(num_rows: int, num_cols: int):
	var chunk_pos := Vector3i(0, 0, 0)

	for row_num in range(num_rows):
		chunk_pos.z = 0
		for col_num in range(num_cols):
			_generate_chunk(chunk_pos)
			chunk_pos.z += CHUNK_SIZE.z
		chunk_pos.x += CHUNK_SIZE.x

func _generate_chunk(pos: Vector3i):
	var cube_positions: Dictionary[Vector3i, int]

	for x in range(pos.x, pos.x + CHUNK_SIZE.x):
		for y in range(-CHUNK_SIZE.y, -1):
			for z in range(pos.z, pos.z + CHUNK_SIZE.z):
				cube_positions[Vector3i(x, y, z)] = 1

	var chunk: StaticBody3D = chunk_scene.instantiate()
	chunk.create_chunk(cube_positions)
	add_child(chunk)

func _generate_random_world(world_size: Vector3i):
	var cube_positions: Dictionary[Vector3i, int]
	var rng := FastNoiseLite.new()
	rng.seed = randi()

	for x in range(world_size.x):
		for y in range(-world_size.y, 0):
			for z in range(world_size.z):
				if rng.get_noise_3d(x, y, z) > 0:
					cube_positions[Vector3i(x, y, z)] = 1

	#chunk.create_surface_with_invisible_faces_hidden(cube_positions)
