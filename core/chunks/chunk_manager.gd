extends Node

@export var chunk_scene: PackedScene

const CHUNK_SIZE := Vector3i(32, 16, 32)

var perlin_noise_generator := FastNoiseLite.new()

func _ready():
	_generate_chunks(3, 3)

func _generate_chunks(num_rows: int, num_cols: int):
	var chunk_pos := Vector3i(0, 0, 0)
	perlin_noise_generator.noise_type = FastNoiseLite.TYPE_SIMPLEX
	perlin_noise_generator.seed = randi()

	for row_num in range(num_rows):
		chunk_pos.z = 0
		for col_num in range(num_cols):
			var chunk: StaticBody3D = chunk_scene.instantiate()
			chunk.create_chunk(chunk_pos, perlin_noise_generator)
			add_child(chunk)

			chunk_pos.z += CHUNK_SIZE.z
		chunk_pos.x += CHUNK_SIZE.x