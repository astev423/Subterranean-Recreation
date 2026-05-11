extends Node

@export var chunk_scene: PackedScene
@export_range(3, 128)
var render_distance: int = 3

@onready var player: CharacterBody3D = get_parent().get_node("Player")

const CHUNK_SIZE := Vector3i(32, 16, 32)
const NUM_GENERATOR_THREADS: int = 4
#var NUM_GENERATOR_THREADS: int = max(1, OS.get_processor_count() - 1)

var perlin_noise_generator := FastNoiseLite.new()
var prev_active_chunk_pos := Vector3i(0, 0, 0)
var cur_active_chunk_pos := Vector3i(0, 0, 0)
var chunks_instantiated: Dictionary[Vector3i, int] = {}

func _ready():
	var camera: Camera3D = player.get_node("Camera3D")
	camera.far = render_distance * CHUNK_SIZE.x

	perlin_noise_generator.noise_type = FastNoiseLite.TYPE_SIMPLEX
	perlin_noise_generator.seed = randi()

	_try_instantiating_chunks(_get_chunk_positions_around_player())

	
func _process(delta: float) -> void:
	if cur_active_chunk_pos != prev_active_chunk_pos:
		# try instantiating new chunks if not visibile yet
		pass

func _get_chunk_positions_around_player() -> Array[Vector3i]:
# Here we treat each chunk as discrete grid component, such as chunk 1 = (0, 0) and chunk 2 = (0, 1)
	var chunk_positions: Array[Vector3i] = []
	@warning_ignore("integer_division")
	var max_chunk_grid_x_pos := (render_distance - 1) / 2
	var min_chunk_grid_x_pos := -max_chunk_grid_x_pos
	var max_chunk_grid_z_pos := max_chunk_grid_x_pos
	var min_chunk_grid_z_pos := min_chunk_grid_x_pos
	
	# Loop for getting top row, next row, etc, all the way to the bottom
	for chunk_grid_x_pos in range(min_chunk_grid_x_pos, max_chunk_grid_x_pos + 1):
		for chunk_grid_z_pos in range(min_chunk_grid_z_pos, max_chunk_grid_z_pos + 1):
			chunk_positions.append(Vector3i(cur_active_chunk_pos.x + chunk_grid_x_pos * CHUNK_SIZE.x,
				cur_active_chunk_pos.y, cur_active_chunk_pos.z + chunk_grid_z_pos * CHUNK_SIZE.z))

	return chunk_positions

func _try_instantiating_chunks(chunk_positions: Array[Vector3i]):
	var chunks_to_make: Array[Vector3i] = []

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
			Thread.new().start(_instantiate_chunks.bind(chunks_to_make.slice(chunks_to_make_index, chunks_to_make_index + num_chunks_per_thread + chunks_to_make.size() % NUM_GENERATOR_THREADS)))
			slice_size += chunks_to_make.size() % NUM_GENERATOR_THREADS
		else:
			Thread.new().start(_instantiate_chunks.bind(chunks_to_make.slice(chunks_to_make_index, chunks_to_make_index + num_chunks_per_thread)))
		
		chunks_to_make_index += slice_size

func _instantiate_chunks(chunk_positions: Array[Vector3i]):
	for chunk_pos in chunk_positions:
		var chunk: StaticBody3D = chunk_scene.instantiate()
		chunk.create_chunk(chunk_pos, perlin_noise_generator)
		# Must defer the adding child to be thread safe
		add_child.call_deferred(chunk)
		chunks_instantiated[chunk_pos] = 1
