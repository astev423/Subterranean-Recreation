extends Node

@export var chunk_scene: PackedScene

const CHUNK_SIZE := Vector3i(32, 16, 32)

var NUM_GENERATOR_THREADS := OS.get_processor_count() - 1
var perlin_noise_generator := FastNoiseLite.new()

func _ready():
	perlin_noise_generator.noise_type = FastNoiseLite.TYPE_SIMPLEX
	perlin_noise_generator.seed = randi()
	var chunk_positions: Array[Vector3i] = []
	var num_rows := 16
	var num_cols := 16
	var chunk_pos := Vector3i(0, 0, 0)

	for row_num in range(num_rows):
		chunk_pos.z = 0
		for col_num in range(num_cols):
			chunk_positions.append(chunk_pos)
			chunk_pos.z += CHUNK_SIZE.z
		chunk_pos.x += CHUNK_SIZE.x

	@warning_ignore("integer_division")
	var num_chunks_per_thread := chunk_positions.size() / NUM_GENERATOR_THREADS
	var chunk_positions_index := 0

	for thread_num in range(NUM_GENERATOR_THREADS):
		var slice_size := num_chunks_per_thread

		if thread_num == NUM_GENERATOR_THREADS - 1:
			Thread.new().start(_generate_chunks.bind(chunk_positions.slice(chunk_positions_index, chunk_positions_index + num_chunks_per_thread + chunk_positions.size() % NUM_GENERATOR_THREADS)))
			slice_size += chunk_positions.size() % NUM_GENERATOR_THREADS
		else:
			Thread.new().start(_generate_chunks.bind(chunk_positions.slice(chunk_positions_index, chunk_positions_index + num_chunks_per_thread)))
		
		chunk_positions_index += slice_size


func _generate_chunks(chunk_positions: Array[Vector3i]):
	for chunk_pos in chunk_positions:
		var chunk: StaticBody3D = chunk_scene.instantiate()
		chunk.create_chunk(chunk_pos, perlin_noise_generator)
		call_deferred("add_child", chunk)
