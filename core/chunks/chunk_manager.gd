extends Node

@export var chunk_scene: PackedScene
# Render distance is the length (and width since they're equal) of square of chunks to render
@export_range(3, 128)
var render_distance: int = 70

@onready var player: CharacterBody3D = get_parent().get_node("Player")
@onready var cur_player_pos := player.global_position

# Chunks start drawing at their position then go position 32 x and z, so chunk -32, 0, -32 goes to 0, 0, 0
const CHUNK_SIZE := Vector3i(32, 16, 32)

var NUM_GENERATOR_THREADS: int = max(1, OS.get_processor_count() - 1)
var noise := FastNoiseLite.new()
var prev_active_chunk_pos := Vector3i(0, 0, 0)
var cur_active_chunk_pos := Vector3i(0, 0, 0)
var chunks_instantiated: Dictionary[Vector3i, int] = {}

func _ready():
	var camera: Camera3D = player.get_node("Camera3D")
	camera.far = render_distance * CHUNK_SIZE.x

	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()

	_try_instantiating_chunks(_get_chunk_positions_around_player())

	
# Check if we need to instantiate new chunks
func _process(_delta: float) -> void:
	cur_player_pos = player.global_position
	var player_x_to_chunk_x_pos := int(player.position.x / CHUNK_SIZE.x) * CHUNK_SIZE.x if player.position.x > 0 else int((player.position.x - 32) / CHUNK_SIZE.x) * CHUNK_SIZE.x
	var player_z_to_chunk_z_pos := int(player.position.z / CHUNK_SIZE.z) * CHUNK_SIZE.z if player.position.z > 0 else int((player.position.z - 32) / CHUNK_SIZE.z) * CHUNK_SIZE.z
	cur_active_chunk_pos = Vector3i(player_x_to_chunk_x_pos, 0, player_z_to_chunk_z_pos)

	if cur_active_chunk_pos != prev_active_chunk_pos:
		_try_instantiating_chunks(_get_chunk_positions_around_player())

	prev_active_chunk_pos = cur_active_chunk_pos

func _try_instantiating_chunks(chunk_positions: Array[Vector3i]):
	var chunks_to_make: Array[Vector3i] = []

	for pos in chunk_positions:
		if chunks_instantiated.has(pos):
			continue

		chunks_instantiated[pos] = 1
		chunks_to_make.append(pos)

	WorkerThreadPool.add_group_task(_instantiate_chunks.bind(chunks_to_make), chunks_to_make.size())

func _get_chunk_positions_around_player() -> Array[Vector3i]:
# Here we treat each chunk as discrete grid component, such as chunk 1 = (0, 0) and chunk 2 = (0, 1)
	var chunk_positions: Array[Vector3i] = []
	@warning_ignore("integer_division")
	var max_chunk_grid_x_pos := (render_distance - 1) / 2
	var min_chunk_grid_x_pos := -max_chunk_grid_x_pos
	var max_chunk_grid_z_pos := max_chunk_grid_x_pos
	var min_chunk_grid_z_pos := min_chunk_grid_x_pos
	
	for chunk_grid_x_pos in range(min_chunk_grid_x_pos, max_chunk_grid_x_pos + 1):
		for chunk_grid_z_pos in range(min_chunk_grid_z_pos, max_chunk_grid_z_pos + 1):
			chunk_positions.append(Vector3i(cur_active_chunk_pos.x + chunk_grid_x_pos * CHUNK_SIZE.x,
				cur_active_chunk_pos.y, cur_active_chunk_pos.z + chunk_grid_z_pos * CHUNK_SIZE.z))

	return chunk_positions

func _instantiate_chunks(index: int, chunks: Array[Vector3i]):
	var chunk: StaticBody3D = chunk_scene.instantiate()
	var chunk_pos := chunks[index]
	chunk.create_chunk(chunk_pos, noise, cur_player_pos)
	# Must defer the adding child to be thread safe
	add_child.call_deferred(chunk)
