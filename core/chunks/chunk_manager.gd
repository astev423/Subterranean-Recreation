extends Node

@export var chunk_scene: PackedScene
@export var render_distance: int = 4

@onready var player: CharacterBody3D = get_parent().get_node("Player")

const CHUNK_SIZE := Vector3i(32, 16, 32)

#var NUM_GENERATOR_THREADS: int = max(1, OS.get_processor_count() - 1)
var NUM_GENERATOR_THREADS: int = 4
var perlin_noise_generator := FastNoiseLite.new()
var prev_active_chunk_pos := Vector3i(0, 0, 0)
var cur_active_chunk_pos := Vector3i(0, 0, 0)
var chunks_instantiated: Dictionary[Vector3i, int] = {}

func _ready():
	var camera: Camera3D = player.get_node("Camera3D")
	camera.far = render_distance * CHUNK_SIZE.x

	perlin_noise_generator.noise_type = FastNoiseLite.TYPE_SIMPLEX
	perlin_noise_generator.seed = randi()

	_generate_chunks(_get_chunk_positions_around_player())

	
func _process(delta: float) -> void:
	if cur_active_chunk_pos != prev_active_chunk_pos:
		# try instantiating new chunks if not visibile yet
		pass

func _get_chunk_positions_around_player() -> Array[Vector3i]:
	var chunk_positions: Array[Vector3i] = []
	# Loop for getting top row, next row, etc, all the way to the bottom
	chunk_positions.append(cur_active_chunk_pos)
	chunk_positions.append(Vector3i(cur_active_chunk_pos.x + CHUNK_SIZE.x, cur_active_chunk_pos.y, cur_active_chunk_pos.z))
	chunk_positions.append(Vector3i(cur_active_chunk_pos.x - CHUNK_SIZE.x, cur_active_chunk_pos.y, cur_active_chunk_pos.z))
	chunk_positions.append(Vector3i(cur_active_chunk_pos.x, cur_active_chunk_pos.y + CHUNK_SIZE.y, cur_active_chunk_pos.z))
	chunk_positions.append(Vector3i(cur_active_chunk_pos.x, cur_active_chunk_pos.y - CHUNK_SIZE.y, cur_active_chunk_pos.z))
	chunk_positions.append(Vector3i(cur_active_chunk_pos.x, cur_active_chunk_pos.y, cur_active_chunk_pos.z + CHUNK_SIZE.z))
	chunk_positions.append(Vector3i(cur_active_chunk_pos.x, cur_active_chunk_pos.y, cur_active_chunk_pos.z + CHUNK_SIZE.z))

	return chunk_positions

func _generate_chunks(chunk_positions: Array[Vector3i]):
	for chunk_pos in chunk_positions:
		var chunk: StaticBody3D = chunk_scene.instantiate()
		chunk.create_chunk(chunk_pos, perlin_noise_generator)
		# Must defer the adding child to be thread safe
		add_child.call_deferred(chunk)
		chunks_instantiated[chunk_pos] = 1

func _try_instantiating_chunks(chunk_positions: Vector3i):
	var chunks_to_make := []

	for chunk_pos in chunk_positions:
		if chunks_instantiated.has(chunk_pos):
			continue

		chunks_to_make.append(chunk_pos)

	@warning_ignore("integer_division")
	var num_chunks_per_thread := chunks_to_make.size() / NUM_GENERATOR_THREADS
	var chunks_to_make_index := 0

	for thread_num in range(NUM_GENERATOR_THREADS):
		var slice_size := num_chunks_per_thread

		if thread_num == NUM_GENERATOR_THREADS - 1:
			Thread.new().start(_generate_chunks.bind(chunks_to_make.slice(chunks_to_make_index, chunks_to_make_index + num_chunks_per_thread + chunks_to_make.size() % NUM_GENERATOR_THREADS)))
			slice_size += chunks_to_make.size() % NUM_GENERATOR_THREADS
		else:
			Thread.new().start(_generate_chunks.bind(chunks_to_make.slice(chunks_to_make_index, chunks_to_make_index + num_chunks_per_thread)))
		
		chunks_to_make_index += slice_size
